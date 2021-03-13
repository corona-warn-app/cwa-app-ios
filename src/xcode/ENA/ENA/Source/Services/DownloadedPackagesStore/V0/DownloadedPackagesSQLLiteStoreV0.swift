//
// 🦠 Corona-Warn-App
//

import FMDB
import Foundation

final class DownloadedPackagesSQLLiteStoreV0 {
	struct StoreError: Error {
		init(_ message: String) {
			self.message = message
		}
		let message: String
	}
	// MARK: Creating a Store

	init(database: FMDatabase) {
		self.database = database
	}

	private func _beginTransaction() {
		database.beginExclusiveTransaction()
	}

	private func _commit() {
		database.commit()
	}

	// MARK: Properties
	private let queue = DispatchQueue(label: "com.sap.DownloadedPackagesSQLLiteStore")
	private let database: FMDatabase
}

extension DownloadedPackagesSQLLiteStoreV0: DownloadedPackagesStoreV0 {
	func open() {
		queue.sync {
			self.database.open()
			self.database.executeStatements(
			"""
			    PRAGMA locking_mode=EXCLUSIVE;
			    PRAGMA auto_vacuum=2;
			    PRAGMA journal_mode=WAL;

			    CREATE TABLE IF NOT EXISTS
			        Z_DOWNLOADED_PACKAGE (
			        Z_BIN BLOB NOT NULL,
			        Z_SIGNATURE BLOB NOT NULL,
			        Z_DAY TEXT NOT NULL,
			        Z_HOUR INTEGER,
			        PRIMARY KEY (
			            Z_DAY,
			            Z_HOUR
			        )
			    );
			"""
		)
		}
	}

	func close() {
		_ = queue.sync {
			self.database.close()
		}
	}

	func set(
		day: String,
		package: SAPDownloadedPackage
	) {
		func deleteHours() -> Bool {
			database.executeUpdate(
				"""
				    DELETE FROM Z_DOWNLOADED_PACKAGE
				    WHERE
				        Z_DAY = :day AND
				        Z_HOUR IS NOT NULL
				    ;
				""",
				withParameterDictionary: ["day": day]
			)
		}
		func insertDay() -> Bool {
			database.executeUpdate(
				"""
				    INSERT INTO
				        Z_DOWNLOADED_PACKAGE (
				            Z_BIN,
				            Z_SIGNATURE,
				            Z_DAY,
				            Z_HOUR
				        )
				        VALUES (
				            :bin,
				            :signature,
				            :day,
				            NULL
				        )
				        ON CONFLICT (
				            Z_DAY,
				            Z_HOUR
				        )
				        DO UPDATE SET
				            Z_BIN = :bin,
				            Z_SIGNATURE = :signature
				    ;
				""",
				withParameterDictionary: [
					"bin": package.bin,
					"signature": package.signature,
					"day": day
				]
			)
		}

		queue.sync {
			self._beginTransaction()

			guard deleteHours() else {
				self.database.rollback()
				return
			}
			guard insertDay() else {
				self.database.rollback()
				return
			}

			self._commit()
		}

	}

	func set(hour: Int, day: String, package: SAPDownloadedPackage) {
		queue.sync {
			let sql = """
				INSERT INTO Z_DOWNLOADED_PACKAGE(
					Z_BIN,
					Z_SIGNATURE,
					Z_DAY,
					Z_HOUR
				)
				VALUES (
					:bin,
					:signature,
					:day,
					:hour
				)
				ON CONFLICT(
					Z_DAY,
					Z_HOUR
				)
				DO UPDATE SET
					Z_BIN = :bin,
					Z_SIGNATURE = :signature
				;
			"""
			let parameters: [String: Any] = [
				"bin": package.bin,
				"signature": package.signature,
				"day": day,
				"hour": hour
			]
			self.database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	func deleteOutdatedDays(now: String) throws {
		let success: Bool = queue.sync {
			let sql = """
			DELETE
				FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_DAY <= Date(:now, '-14 days');
			"""
			return self.database.executeUpdate(sql, withParameterDictionary: ["now": now])
		}
		guard success else {
			throw StoreError(self.database.lastErrorMessage())
		}
	}

	func package(for day: String) -> SAPDownloadedPackage? {
		queue.sync {
			let sql = """
				SELECT
					Z_BIN,
					Z_SIGNATURE
				FROM Z_DOWNLOADED_PACKAGE
				WHERE
					Z_DAY = :day AND
					Z_HOUR IS NULL
				;
			"""
			guard let result = self.database.execute(query: sql, parameters: ["day": day]) else {
				return nil
			}

			defer { result.close() }
			return result
				.map { $0.downloadedPackage() }
				.compactMap { $0 }
				.first
		}
	}

	func hourlyPackages(for day: String) -> [SAPDownloadedPackage] {
		queue.sync {
			let sql = "SELECT Z_BIN, Z_SIGNATURE, Z_HOUR FROM Z_DOWNLOADED_PACKAGE WHERE Z_DAY = :day AND Z_HOUR IS NOT NULL ORDER BY Z_HOUR DESC;"
			guard let result = self.database.execute(query: sql, parameters: ["day": day]) else {
				return []
			}
			defer { result.close() }
			return result
				.map { $0.downloadedPackage() }
				.compactMap { $0 }
		}
	}

	func allDays() -> [String] {
		queue.sync {
			let sql = "SELECT Z_DAY FROM Z_DOWNLOADED_PACKAGE WHERE Z_HOUR IS NULL;"
			guard let result = self.database.execute(query: sql) else {
				return []
			}
			defer { result.close() }
			return result
				.map { $0.string(forColumn: "Z_DAY") }
				.compactMap { $0 }
		}
	}

	func hours(for day: String) -> [Int] {
		let sql =
			"""
			    SELECT
			        Z_HOUR
			    FROM
			        Z_DOWNLOADED_PACKAGE
			    WHERE
			        Z_HOUR IS NOT NULL AND Z_DAY = :day
			    ;
			"""
		return queue.sync {
			guard let result = self.database.execute(query: sql, parameters: ["day": day]) else {
				return []
			}
			defer { result.close() }
			return result.map { Int($0.int(forColumn: "Z_HOUR")) }
		}
	}

	func reset() {
		_ = queue.sync {
			self.database.executeStatements(
				"""
					PRAGMA journal_mode=OFF;
					DROP TABLE Z_DOWNLOADED_PACKAGE;
					VACUUM;
				"""
			)
		}
	}
}

private extension FMDatabase {
	func execute(
		query sql: String,
		parameters: [AnyHashable: Any] = [:]
	) -> FMResultSet? {
		executeQuery(sql, withParameterDictionary: parameters)
	}
}

private extension FMResultSet {
	func map<T>(transform: (FMResultSet) -> T) -> [T] {
		var mapped = [T]()
		while next() {
			mapped.append(transform(self))
		}
		return mapped
	}

	func downloadedPackage() -> SAPDownloadedPackage? {
		guard
			let bin = data(forColumn: "Z_BIN"),
			let signature = data(forColumn: "Z_SIGNATURE") else {
			return nil
		}
		return SAPDownloadedPackage(keysBin: bin, signature: signature)
	}
}

extension DownloadedPackagesSQLLiteStoreV0 {
	convenience init(fileName: String) {

		let fileManager = FileManager()
		guard let documentDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		// on-the-fly migration for older installations
		Self.migrate(fileName: fileName, to: storeURL)

		let db = FMDatabase(url: storeURL)
		self.init(database: db)
		self.open()
	}

	// Quick and dirty
	private static func migrate(fileName: String, to newURL: URL) {
		let fileManager = FileManager.default
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let oldStoreURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		if fileManager.fileExists(atPath: oldStoreURL.path) {
			do {
				try fileManager.moveItem(atPath: oldStoreURL.path, toPath: newURL.path)
			} catch {
				Log.error("Cannot move file to new location. Error: \(error)", log: .localData, error: error)
			}
		}
	}
}
