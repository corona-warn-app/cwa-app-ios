//
// 🦠 Corona-Warn-App
//

import FMDB
import Foundation

final class DownloadedPackagesSQLLiteStoreV3 {

	enum StoreError: Error {
		case sqliteError(SQLiteErrorCode)
		case revokedPackage
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
		#if DEBUG
		if ProcessInfo.processInfo.arguments.contains("-SQLLog") {
			// trace executed SQL statements
			database.traceExecution = true
		}
		#endif
	}

	deinit {
		database.close()
	}

	private func _beginTransaction() {
		database.beginExclusiveTransaction()
	}

	private func _commit() {
		database.commit()
	}

	// MARK: Properties

	var keyValueStore: Store?

	var revokationList: [String] = []
	
	private let latestVersion: Int
	private let queue = DispatchQueue(label: "com.sap.DownloadedPackagesSQLLiteStore")
	private let database: FMDatabase
	private let migrator: SerialMigratorProtocol
}

// swiftlint:disable file_length
extension DownloadedPackagesSQLLiteStoreV3: DownloadedPackagesStoreV3 {

	func open() { // might throw errors in future versions!
		queue.sync {
			
			guard self.database.open() else {
				Log.error("Error at opening the database", log: .localData, error: self.database.lastError())
				fatalError("Developer error. Probably no database file accessible.")
			}

			if self.database.tableExists("Z_DOWNLOADED_PACKAGE") {
				// tbd: what to do on errors?
				do {
					try self.migrator.migrate()
				} catch {
					Log.error("Migration error", log: .localData, error: error)
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
						Z_ETAG STRING NULL,
						Z_HASH STRING NULL,
						Z_CHECKED_FOR_EXPOSURES INTEGER DEFAULT 0,
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
		queue.sync {
			guard self.database.close() else {
				Log.error("Can't close database!", log: .localData, error: nil)
				return
			}
		}
	}

	// MARK: - Write Operations
	
	func markPackagesAsCheckedForExposures(_ fingerprints: [String]) throws {
		try queue.sync {
			// ['a', 'b', 'c'] --> ?, ?, ?
			let fingerprintParams = Array(repeating: "?", count: fingerprints.count).joined(separator: ", ")
			
			let sql = """
				UPDATE
					Z_DOWNLOADED_PACKAGE
				SET
					Z_CHECKED_FOR_EXPOSURES = 1,
					Z_BIN = ?,
					Z_SIGNATURE = ?
				WHERE
					Z_HASH
				IN
					(\(fingerprintParams))
				;
			"""
			
			// Set 'bin' and 'signature' to (nearly) empty data. (For the first two '?' in the query).
			// It still needs to be set to some tiny data blob ("42"), otherwise FMDB will return nil while reading it.
			// We are setting it to empty data to free up disk space, because the keys in these packages are not used anymore for risk calculation.
			var parameters: [Any] = [
				"42".data(using: .utf8) ?? Data(),
				"42".data(using: .utf8) ?? Data()
			]
			
			// Append fingerprints for the other '?' in the search query 'IN'.
			parameters.append(contentsOf: fingerprints)
			
			do {
				try database.executeUpdate(sql, values: parameters)
			} catch {
				Log.error("[SQLite] (\(database.lastErrorCode()) \(database.lastErrorMessage())", log: .localData)
				let sqliteError = SQLiteErrorCode(rawValue: database.lastErrorCode())
				throw StoreError.sqliteError(sqliteError)
			}
		}
	}

	func set(country: Country.ID, hour: Int, day: String, etag: String?, package: SAPDownloadedPackage?) throws {
		guard !revokationList.contains(etag ?? ""),
			  let package = package else {
			// Package is on block list.
			Log.info("[DownloadedPackagesSQLLiteStoreV2] Revoke hour package day: \(day) hour: \(hour) with etag: \(String(describing: etag)) for country: \(country)")
			throw StoreError.revokedPackage
		}

		try queue.sync {
			Log.info("[DownloadedPackagesSQLLiteStoreV2] Persist hour package day: \(day) hour: \(hour) with etag: \(String(describing: etag)) for country: \(country)")

			let sql = """
				INSERT INTO Z_DOWNLOADED_PACKAGE (
					Z_BIN,
					Z_SIGNATURE,
					Z_DAY,
					Z_HOUR,
					Z_COUNTRY,
					Z_ETAG,
					Z_HASH,
					Z_CHECKED_FOR_EXPOSURES
				)
				VALUES (
					:bin,
					:signature,
					:day,
					:hour,
					:country,
					:etag,
					:hash,
					:checkedForExposures
				)
				ON CONFLICT(
					Z_COUNTRY,
					Z_DAY,
					Z_HOUR
				)
				DO UPDATE SET
					Z_BIN = :bin,
					Z_SIGNATURE = :signature,
					Z_HASH = :hash
				;
			"""
			let parameters: [String: Any] = [
				"bin": package.bin,
				"signature": package.signature,
				"day": day,
				"hour": hour,
				"country": country,
				"etag": etag ?? NSNull(),
				"hash": package.fingerprint,
				"checkedForExposures": 0
			]
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				let sqliteError = SQLiteErrorCode(rawValue: database.lastErrorCode())
				throw StoreError.sqliteError(sqliteError)
			}
		}
	}

	func set(country: Country.ID, day: String, etag: String?, package: SAPDownloadedPackage?) throws {
		guard !revokationList.contains(etag ?? ""),
			  let package = package else {
			// Package is on block list.
			Log.info("[DownloadedPackagesSQLLiteStoreV2] Revoke package \(day) with etag: \(String(describing: etag)) for country: \(country)")
			throw StoreError.revokedPackage
		}

		#if !RELEASE
		if let store = keyValueStore, let errorCode = store.fakeSQLiteError {
			let sqliteError = SQLiteErrorCode(rawValue: errorCode)
			throw StoreError.sqliteError(sqliteError)
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
			Log.info("[DownloadedPackagesSQLLiteStoreV2] persist package \(day) with etag: \(String(describing: etag)) for country: \(country)")

			return database.executeUpdate(
				"""
					INSERT INTO
						Z_DOWNLOADED_PACKAGE (
							Z_BIN,
							Z_SIGNATURE,
							Z_DAY,
							Z_HOUR,
							Z_COUNTRY,
							Z_ETAG,
							Z_HASH,
							Z_CHECKED_FOR_EXPOSURES
						)
						VALUES (
							:bin,
							:signature,
							:day,
							NULL,
							:country,
							:etag,
							:hash,
							:checkedForExposures
						)
						ON CONFLICT (
							Z_COUNTRY,
							Z_DAY,
							Z_HOUR
						)
						DO UPDATE SET
							Z_BIN = :bin,
							Z_SIGNATURE = :signature,
							Z_HASH = :hash
					;
				""",
				withParameterDictionary: [
					"bin": package.bin,
					"signature": package.signature,
					"day": day,
					"country": country,
					"etag": etag ?? NSNull(),
					"hash": package.fingerprint,
					"checkedForExposures": 0
				]
			)
		}

		try queue.sync {
			self._beginTransaction()

			guard deleteHours(), insertDay() else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				let sqliteError = SQLiteErrorCode(rawValue: database.lastErrorCode())
				throw StoreError.sqliteError(sqliteError)
			}
			self._commit()
		}
	}

	// MARK: - Fetch Operations

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

	func packages(with etag: String?) -> [SAPDownloadedPackage]? {
		queue.sync {
			let sql = """
				SELECT
					Z_BIN,
					Z_SIGNATURE
				FROM Z_DOWNLOADED_PACKAGE
				WHERE
					Z_ETAG IS :etag
				;
			"""

			let parameters: [String: Any] = [
				"etag": etag ?? NSNull()
			]

			guard let result = self.database.execute(query: sql, parameters: parameters) else {
				return nil
			}
			defer { result.close() }
			return result
				.map { $0.downloadedPackage() }
				.compactMap { $0 }
		}
	}

	func packages(with etags: [String]) -> [SAPDownloadedPackage]? {
		queue.sync {
			// ['a', 'b', 'c'] --> ?, ?, ?
			let params = Array(repeating: "?", count: etags.count).joined(separator: ", ")
			let sql = """
				SELECT
					Z_BIN,
					Z_SIGNATURE
				FROM Z_DOWNLOADED_PACKAGE
				WHERE
					Z_ETAG
				IN
					(\(params))
				;
			"""
			do {
				let result = try self.database.executeQuery(sql, values: etags)
				return result
					.map { $0.downloadedPackage() }
					.compactMap { $0 }
			} catch {
				Log.error("[SQLite] (\(database.lastErrorCode()): \(database.lastErrorMessage()))", log: .localData)
				return nil // tbd: throws
			}
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

	func hourlyPackagesNotCheckedForExposure(for day: String, country: Country.ID) -> [SAPDownloadedPackage] {
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
					Z_HOUR IS NOT NULL AND
					Z_CHECKED_FOR_EXPOSURES = :checkedForExposures
				ORDER BY
					Z_HOUR DESC
				;
			"""

			let parameters: [String: Any] = [
				"day": day,
				"country": country,
				"checkedForExposures": 0
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
	
	func allDaysNotCheckedForExposure(country: Country.ID) -> [String] {
		queue.sync {
			let sql = """
				SELECT
					Z_DAY
				FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_COUNTRY = :country AND
					Z_HOUR IS NULL AND
					Z_CHECKED_FOR_EXPOSURES = 0
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

	// MARK: - Remove/Delete Operations

	func delete(package: SAPDownloadedPackage) throws {
		try delete(packages: [package])
	}

	func delete(packages: [SAPDownloadedPackage]) throws {
		guard !packages.isEmpty else { return }

		Log.info("Delete key packages with fingerprint: \(packages.map { $0.fingerprint })", log: .localData)

		// Reset the download flags to ensure that the KeyPackageDownload will download packages after revoked packages were deleted.
		keyValueStore?.wasRecentDayKeyDownloadSuccessful = false
		keyValueStore?.wasRecentHourKeyDownloadSuccessful = false

		try queue.sync {
			let fingerprints = packages.map({ $0.fingerprint })
			// ['a', 'b', 'c'] --> ?, ?, ?
			let params = Array(repeating: "?", count: fingerprints.count).joined(separator: ", ")
			let sql = """
				DELETE FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_HASH
				IN
					(\(params))
				;
			"""
			do {
				try database.executeUpdate(sql, values: fingerprints)
			} catch {
				Log.error("[SQLite] (\(database.lastErrorCode()) \(database.lastErrorMessage())", log: .localData)
				let sqliteError = SQLiteErrorCode(rawValue: database.lastErrorCode())
				throw StoreError.sqliteError(sqliteError)
			}
		}
	}

	func deleteOldPackages(before referenceDate: String) {
		queue.sync {
			let sql = """
				DELETE FROM
					Z_DOWNLOADED_PACKAGE
				WHERE
					Z_DAY < :referenceDate
				;
			"""

			let parameters: [String: Any] = ["referenceDate": referenceDate]
			self.database.executeUpdate(sql, withParameterDictionary: parameters)
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

// MARK: - Extensions

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

extension DownloadedPackagesSQLLiteStoreV3 {
	convenience init(fileName: String) {

		let fileManager = FileManager.default
		guard let documentDir = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		Self.migrate(fileName: fileName, to: storeURL)
		let db = FMDatabase(url: storeURL)

		let latestDBVersion = 3
		let migrations: [Migration] = [
			Migration0To1(database: db),
			Migration1To2(database: db),
			Migration2To3(database: db)
		]
		let migrator = SerialMigrator(latestVersion: latestDBVersion, database: db, migrations: migrations)
		self.init(database: db, migrator: migrator, latestVersion: latestDBVersion)
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
		
		// Remove old temp files
		let tempFileURLs = [
			documentDir
					.appendingPathComponent(fileName)
					.appendingPathExtension("sqlite3-shm"),
			documentDir
					.appendingPathComponent(fileName)
					.appendingPathExtension("sqlite3-wal")
		]
		
		for tempFileURL in tempFileURLs {
			if fileManager.fileExists(atPath: tempFileURL.path) {
				do {
					try fileManager.removeItem(at: tempFileURL)
				} catch {
					Log.error("Cannot remove old sqlite temp files. Error: \(error)", log: .localData, error: error)
				}
			}
		}
	}
}
