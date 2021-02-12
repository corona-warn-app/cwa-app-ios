//
// 🦠 Corona-Warn-App
//

import FMDB
import Foundation

final class DownloadedPackagesSQLLiteStoreV1 {

	struct StoreError: Error {
		init(_ message: String) {
			self.message = message
		}
		let message: String
	}
	// MARK: Creating a Store

	init(
		database: FMDatabase,
		migrator: SerialMigratorProtocol,
		latestVersion: Int
	) {
		self.database = database
		self.migrator = migrator
		self.latestVersion = latestVersion
	}

	private func _beginTransaction() {
		database.beginExclusiveTransaction()
	}

	private func _commit() {
		database.commit()
	}

	// MARK: Properties

	#if !RELEASE

	var keyValueStore: Store?

	#endif

	private let latestVersion: Int
	private let queue = DispatchQueue(label: "com.sap.DownloadedPackagesSQLLiteStore")
	private let database: FMDatabase
	private let migrator: SerialMigratorProtocol
}

extension DownloadedPackagesSQLLiteStoreV1: DownloadedPackagesStoreV1 {
	func open() {
		queue.sync {
			self.database.open()

			if self.database.tableExists("Z_DOWNLOADED_PACKAGE") {
				do {
					try self.migrator.migrate()
				} catch {
					Log.error("Migration failed!", log: .localData, error: error)
					fatalError("Migration failed! \(error)")
				}
			} else {
				self.database.executeStatements(
				"""
					PRAGMA locking_mode=EXCLUSIVE;
					PRAGMA auto_vacuum=2;
					PRAGMA journal_mode=WAL;

					CREATE TABLE
						Z_DOWNLOADED_PACKAGE (
						Z_BIN BLOB NOT NULL,
						Z_SIGNATURE BLOB NOT NULL,
						Z_DAY TEXT NOT NULL,
						Z_HOUR INTEGER,
						Z_COUNTRY STRING NOT NULL,
						PRIMARY KEY (
							Z_COUNTRY,
							Z_DAY,
							Z_HOUR
						)
					);
				"""
				)
				self.database.userVersion = UInt32(self.latestVersion)
			}
		}
	}

	func close() {
		_ = queue.sync {
			self.database.close()
		}
	}

	@discardableResult
	func set(
		country: Country.ID,
		day: String,
		package: SAPDownloadedPackage
	) -> Result<Void, SQLiteErrorCode> {

		#if !RELEASE

		if let store = keyValueStore, let errorCode = store.fakeSQLiteError {
			return .failure(error(for: errorCode))
		}

		#endif

		func deleteHours() -> Bool {
			database.executeUpdate(
				"""
				    DELETE FROM Z_DOWNLOADED_PACKAGE
				    WHERE
						Z_COUNTRY = :country AND
				        Z_DAY = :day AND
				        Z_HOUR IS NOT NULL
				    ;
				""",
				withParameterDictionary: [
					"country": country,
					"day": day
				]
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
				            Z_HOUR,
							Z_COUNTRY
				        )
				        VALUES (
				            :bin,
				            :signature,
				            :day,
				            NULL,
							:country
				        )
				        ON CONFLICT (
							Z_COUNTRY,
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
					"day": day,
					"country": country
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

		let lastErrorCode = database.lastErrorCode()
		if lastErrorCode == 0 {
			return .success(())
		} else {
			return .failure(error(for: lastErrorCode))
		}
	}

	private func error(for sqliteErrorCode: Int32) -> SQLiteErrorCode {
		if let error = SQLiteErrorCode(rawValue: sqliteErrorCode) {
			return error
		} else {
			return .unknown
		}
	}

	@discardableResult
	func set(
		country: Country.ID,
		hour: Int,
		day: String,
		package: SAPDownloadedPackage
	) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			let sql = """
				INSERT INTO Z_DOWNLOADED_PACKAGE(
					Z_BIN,
					Z_SIGNATURE,
					Z_DAY,
					Z_HOUR,
					Z_COUNTRY
				)
				VALUES (
					:bin,
					:signature,
					:day,
					:hour,
					:country
				)
				ON CONFLICT(
					Z_COUNTRY,
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
				"hour": hour,
				"country": country
			]
			self.database.executeUpdate(sql, withParameterDictionary: parameters)
		}

		let lastErrorCode = database.lastErrorCode()
		if lastErrorCode == 0 {
			return .success(())
		} else {
			return .failure(error(for: lastErrorCode))
		}
	}

	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage? {
		queue.sync {
			let sql = """
				SELECT
					Z_BIN,
					Z_SIGNATURE
				FROM Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_DAY = :day AND
					Z_HOUR IS NULL
				;
			"""

			let parameters: [String: Any] = [
				"day": day,
				"country": country
			]

			guard let result = self.database.execute(query: sql, parameters: parameters) else {
				return nil
			}

			defer { result.close() }
			return result
				.map { $0.downloadedPackage() }
				.compactMap { $0 }
				.first
		}
	}

	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage] {
		queue.sync {
			let sql = """
				SELECT
					Z_BIN,
					Z_SIGNATURE,
					Z_HOUR
				FROM Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_DAY = :day AND
					Z_HOUR IS NOT NULL
				ORDER BY
					Z_HOUR DESC
				;
			"""

			let parameters: [String: Any] = [
				"day": day,
				"country": country
			]

			guard let result = self.database.execute(query: sql, parameters: parameters) else {
				return []
			}
			defer { result.close() }
			return result
				.map { $0.downloadedPackage() }
				.compactMap { $0 }
		}
	}

	func allDays(country: Country.ID) -> [String] {
		queue.sync {
			let sql = """
				SELECT
					Z_DAY
				FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_HOUR IS NULL
				;
			"""

			let parameters: [String: Any] = [
				"country": country
			]

			guard let result = self.database.execute(query: sql, parameters: parameters) else {
				return []
			}
			defer { result.close() }
			return result
				.map { $0.string(forColumn: "Z_DAY") }
				.compactMap { $0 }
		}
	}

	func hours(for day: String, country: Country.ID) -> [Int] {
		let sql =
			"""
			    SELECT
			        Z_HOUR
			    FROM
			        Z_DOWNLOADED_PACKAGE
			    WHERE
			        Z_HOUR IS NOT NULL AND
					Z_DAY = :day AND
					Z_COUNTRY = :country
			    ;
			"""

		let parameters: [String: Any] = [
			"day": day,
			"country": country
		]

		return queue.sync {
			guard let result = self.database.execute(query: sql, parameters: parameters) else {
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
	
	func deleteDayPackage(for day: String, country: Country.ID) {
		queue.sync {
			let sql = """
				DELETE FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_DAY = :day AND
					Z_HOUR IS NULL
				;
			"""
			
			let parameters: [String: Any] = ["country": country, "day": day]
			self.database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	func deleteHourPackage(for day: String, hour: Int, country: Country.ID) {
		queue.sync {
			let sql = """
				DELETE FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_DAY = :day AND
					Z_HOUR = :hour
				;
			"""
			let parameters: [String: Any] = [
				"country": country,
				"day": day,
				"hour": hour
			]
			self.database.executeUpdate(sql, withParameterDictionary: parameters)
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

extension DownloadedPackagesSQLLiteStoreV1 {
	convenience init(fileName: String) {

		let fileManager = FileManager()
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		let db = FMDatabase(url: storeURL)

		let latestDBVersion = 1
		let migration0To1 = Migration0To1(database: db)
		let migrator = SerialMigrator(latestVersion: latestDBVersion, database: db, migrations: [migration0To1])
		self.init(database: db, migrator: migrator, latestVersion: latestDBVersion)
		self.open()
	}
}

extension DownloadedPackagesStoreV1 {

	@discardableResult
	func addFetchedDays(_ dayPackages: [String: SAPDownloadedPackage], country: Country.ID) -> Result<Void, SQLiteErrorCode> {
		var errors = [SQLiteErrorCode]()

		dayPackages.forEach { day, bucket in
			let result = self.set(country: country, day: day, package: bucket)

			switch result {
			case .success:
				break
			case .failure(let error):
				errors.append(error)
			}
		}

		if let error = errors.first {
			return .failure(error)
		} else {
			return .success(())
		}
	}

	@discardableResult
	func addFetchedHours(_ hourPackages: [Int: SAPDownloadedPackage], day: String, country: Country.ID) -> Result<Void, SQLiteErrorCode> {
		var errors = [SQLiteErrorCode]()

		hourPackages.forEach { hour, bucket in
			let result = self.set(country: country, hour: hour, day: day, package: bucket)

			switch result {
			case .success:
				break
			case .failure(let error):
				errors.append(error)
			}
		}

		if let error = errors.first {
			return .failure(error)
		} else {
			return .success(())
		}
	}
}
