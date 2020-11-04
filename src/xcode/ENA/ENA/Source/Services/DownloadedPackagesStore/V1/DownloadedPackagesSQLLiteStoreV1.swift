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
				self.migrator.migrate()
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

	func set(
		country: Country.ID,
		day: String,
		package: SAPDownloadedPackage,
		completion: ((SQLiteErrorCode?) -> Void)? = nil
	) {

		#if !RELEASE

		if let store = keyValueStore, let errorCode = store.fakeSQLiteError {
			failAsyncWithError(completion: completion, errorCode: errorCode)
			return
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
				self.failAsyncWithError(completion: completion, errorCode: database.lastErrorCode())
				return
			}
			guard insertDay() else {
				self.database.rollback()
				self.failAsyncWithError(completion: completion, errorCode: database.lastErrorCode())
				return
			}

			self._commit()

			self.completeAsync(completion: completion)
		}

	}

	private func failAsyncWithError(completion: ((SQLiteErrorCode?) -> Void)?, errorCode: Int32) {
		DispatchQueue.global().async {
			if let error = SQLiteErrorCode(rawValue: errorCode) {
				completion?(error)
			} else {
				completion?(.unknown)
			}
		}
	}

	private func completeAsync(completion: ((SQLiteErrorCode?) -> Void)?) {
		DispatchQueue.global().async {
			completion?(nil)
		}
	}

	func set(
		country: Country.ID,
		hour: Int,
		day: String,
		package: SAPDownloadedPackage
	) {
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
