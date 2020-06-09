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

/// Basic SQLite Key/Value store with Keys as `TEXT` and Values stored as `BLOB`
class SQLiteKeyValueStore {
	private let databaseQueue: FMDatabaseQueue?
	private let directoryURL: URL

	/// - parameter url: URL on disk where the FMDB should be initialized
	/// If any part of the init fails no Datbase will be created
	/// If the Database can't be accessed with the key the currentFile will be reset
	init(with url: URL?, key: String) {
		guard let url = url else {
			fatalError("Creating the Database failed")
		}

		self.directoryURL = url
		let fileURL = directoryURL.appendingPathComponent("secureStore.sqlite")
		databaseQueue = FMDatabaseQueue(url: fileURL)
		initDatabase(key, retry: false)
	}

	deinit {
		databaseQueue?.close()
	}

	/// Generates or Loads Database Key
	/// Creates the K/V Datsbase if it is not already there
	private func initDatabase(_ key: String, retry: Bool) {
		var noDatabaseAccess = false
		databaseQueue?.inDatabase { db in
			let dbhandle = OpaquePointer(db.sqliteHandle)
			guard sqlite3_key(dbhandle, key, Int32(key.count)) == SQLITE_OK else {
				logError(message: "Unable to set Key")
				return
			}
			let sqlStmt = """
			PRAGMA auto_vacuum=2;

			CREATE TABLE IF NOT EXISTS kv (
				key TEXT UNIQUE,
				value BLOB
			);
			"""
			if !db.executeStatements(sqlStmt) {
				noDatabaseAccess = true
			}
		}
		if noDatabaseAccess && !retry {
			resetDatabase()
			initDatabase(key, retry: true)
		}

	}

	///Open Database Connection, set the Key and check if the Key/Value Table already exits.
	/// This retries the init steps, in case there was an issue
	private func openDbIfNeeded() {
		databaseQueue?.inDatabase { db in
			if !db.isOpen {
				db.open()
			}
		}
	}

	/// - returns: `Data` if the key/value pair in the DB, `nil` otherwise
	private func getData(for key: String) -> Data? {
		openDbIfNeeded()

		var dataToReturn: Data?
		databaseQueue?.inDatabase { db in
			do {
				let query = "SELECT value FROM kv WHERE key = ?;"
				let result = try db.executeQuery(query, values: [key])
				var resultData: Data?
				while result.next() {
					// We use dataNoCopy() as data() returns nil even though there is empty Data
					// This is unexpected, as empty Data of course does not mean nil
					guard let data = result.dataNoCopy(forColumn: "value") else {
						return
					}
					resultData = data
				}
				result.close()
				dataToReturn = resultData
				return
			} catch {
				logError(message: "Failed to retrieve value from K/V SQLite store: \(error.localizedDescription)")
				return
			}
		}
		return dataToReturn
	}

	/// Sets or overwrites the value for a given key
	/// - attention: Passing `nil` to the data param causes the key/value pair to be deleted from the DB
	private func setData(_ data: Data?, for key: String) {
		openDbIfNeeded()
		databaseQueue?.inDatabase { db in
			guard let data = data else {
				let deleteStmt = "DELETE FROM kv WHERE key = ?;"
				do {
					try db.executeUpdate(deleteStmt, values: [key])
					try db.executeUpdate("VACUUM", values: [])
				} catch {
					logError(message: "Failed to delete key from K/V SQLite store: \(error.localizedDescription)")
				}
				return
			}

			/// Insert the key/value pair if it isn't already in the Database, otherwise Update the value
			let upsertStmt = "INSERT INTO kv(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value = ?"
			do {
				try db.executeUpdate(upsertStmt, values: [key, data, data])
			} catch {
				logError(message: "Failed to insert key/V pair into K/V SQLite store: \(error.localizedDescription)")
			}
		}
	}

	/// Removes all key/value pairs from the Store
	func clearAll(key: String?) {
		openDbIfNeeded()
		databaseQueue?.inDatabase { db in
			let sqlStmt = """
			PRAGMA journal_mode=OFF;
			DROP TABLE kv;
			VACUUM;
			"""
			db.executeStatements(sqlStmt)
		}
		resetDatabase()
		guard let key = key else {
			return
		}

		initDatabase(key, retry: false)
	}

	/// Removes the Database File to clear everything
	private func resetDatabase() {
		databaseQueue?.close()
		do {
			try FileManager.default.removeItem(at: directoryURL)
			try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
		} catch {
			logError(message: "Failed to delete database file")
		}
	}

	/// Removes most key/value pairs.
	///
	/// Keys whose values are not removed:
	/// - `developerSubmissionBaseURLOverride`
	/// - `developerDistributionBaseURLOverride`
	/// - `developerVerificationBaseURLOverride`
	func flush() {
		openDbIfNeeded()
		databaseQueue?.inDatabase { db in
			let deleteStmt = "DELETE FROM kv WHERE key NOT IN('developerSubmissionBaseURLOverride','developerDistributionBaseURLOverride','developerVerificationBaseURLOverride');"
			do {
				try db.executeUpdate(deleteStmt, values: [])
				try db.executeUpdate("VACUUM", values: [])
				log(message: "Flushed SecureStore", level: .info)
			} catch {
				logError(message: "Failed to delete key from K/V SQLite store: \(error.localizedDescription)")
			}
		}
	}

	/// - parameter key: key index to look in the DB for
	/// - returns: `Data` if the key/value pair is found (even if the value BLOB is empty), or nil if no value exists for the given key.
	subscript(key: String) -> Data? {
		get {
			getData(for: key)
		}
		set {
			setData(newValue, for: key)
		}
	}

	/// Convenience subscript to use with `Codable` types, uses JSON encoder/decoder with no additional configuration.
	/// - returns: Model decoded with a `JSONDecoder`, or `nil` if decoding fails.
	///
	/// - attention: Errors encountered during encoding with `JSONEncoder` silently fail (but are logged)!
	///	If encoding fails, fetching the value for that key will result in empty `Data`
	subscript<Model: Codable>(key: String) -> Model? {
		get {
			guard let data = getData(for: key) else {
				return nil
			}
			return try? JSONDecoder().decode(Model.self, from: data)
		}
		set {
			do {
				let encoded = try JSONEncoder().encode(newValue)
				setData(encoded, for: key)
			} catch {
				logError(message: "Error when encoding value for inserting into K/V SQLite store: \(error.localizedDescription)")
			}
		}
	}
}

/// Extensions for Hexencoding when generating key
extension Data {
	func hexEncodedString() -> String {
		map { String(format: "%02hhX", $0) }.joined()
	}
}
