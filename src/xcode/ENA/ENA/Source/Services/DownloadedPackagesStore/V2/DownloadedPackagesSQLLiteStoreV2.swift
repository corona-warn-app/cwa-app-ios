// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import FMDB
import Foundation

final class DownloadedPackagesSQLLiteStoreV2 {

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

	#if !RELEASE
	var keyValueStore: Store?
	#endif

	var revokationList: [String] = []
	
	private let latestVersion: Int
	private let queue = DispatchQueue(label: "com.sap.DownloadedPackagesSQLLiteStore")
	private let database: FMDatabase
	private let migrator: SerialMigratorProtocol
}

extension DownloadedPackagesSQLLiteStoreV2: DownloadedPackagesStoreV2 {

	func open() { // might throw errors in future versions!
		queue.sync {
			self.database.open()

			if self.database.tableExists("Z_DOWNLOADED_PACKAGE") {
				// tbd: what to do on errors?
				try? self.migrator.migrate()
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

	// MARK: - Write Operations

	func set(country: Country.ID, hour: Int, day: String, etag: String?, package: SAPDownloadedPackage) throws {
		guard !revokationList.contains(etag ?? "") else {
			// package is on block list. Ignore this set operation.
			return
		}

		try queue.sync {
			let sql = """
				INSERT INTO Z_DOWNLOADED_PACKAGE (
					Z_BIN,
					Z_SIGNATURE,
					Z_DAY,
					Z_HOUR,
					Z_COUNTRY,
					Z_ETAG,
					Z_HASH
				)
				VALUES (
					:bin,
					:signature,
					:day,
					:hour,
					:country,
					:etag,
					:hash
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
				"country": country,
				"etag": etag ?? NSNull(),
				"hash": package.fingerprint
			]
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				throw SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
			}
		}
	}

	func set(country: Country.ID, day: String, etag: String?, package: SAPDownloadedPackage) throws {
		guard !revokationList.contains(etag ?? "") else {
			// package is on block list. Ignore this set operation.
			return
		}

		#if !RELEASE
		if let store = keyValueStore, let errorCode = store.fakeSQLiteError {
			throw SQLiteErrorCode(rawValue: errorCode) ?? SQLiteErrorCode.unknown
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
							Z_COUNTRY,
							Z_ETAG,
							Z_HASH
						)
						VALUES (
							:bin,
							:signature,
							:day,
							NULL,
							:country,
							:etag,
							:hash
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
					"country": country,
					"etag": etag ?? NSNull(),
					"hash": package.fingerprint
				]
			)
		}

		try queue.sync {
			self._beginTransaction()

			guard deleteHours(), insertDay() else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				throw SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
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

	// MARK: - Remove/Delete Operations

	func delete(package: SAPDownloadedPackage) throws {
		try delete(packages: [package])
	}

	func delete(packages: [SAPDownloadedPackage]) throws {
		guard !packages.isEmpty else { return }
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
				throw SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
			}
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

extension DownloadedPackagesSQLLiteStoreV2 {
	convenience init(fileName: String) {

		let fileManager = FileManager()
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		let db = FMDatabase(url: storeURL)

		let latestDBVersion = 2
		let migrations: [Migration] = [Migration0To1(database: db), Migration1To2(database: db)]
		let migrator = SerialMigrator(latestVersion: latestDBVersion, database: db, migrations: migrations)
		self.init(database: db, migrator: migrator, latestVersion: latestDBVersion)
		self.open()
	}
}
