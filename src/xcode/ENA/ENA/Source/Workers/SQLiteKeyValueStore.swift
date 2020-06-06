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
	private let db: FMDatabase

	/// - parameter url: URL on disk where the FMDB should be initialized
	/// If any part of the init fails no Datbase will be created
	/// If the Database can't be accessed with the key the currentFile will be reset
	init(with url: URL) {
		db = FMDatabase(url: url)
		if !db.open() {
			logError(message: "Database could not be opened")
			return
		}
		initDatabase()
	}

	deinit {
		db.close()
	}

	/// Generates or Loads Database Key
	/// Creates the K/V Datsbase if it is not already there
	private func initDatabase() {
		var key: String

		if checkInitalSetup() {
			guard let generatedKey = generateDatabaseKey() else {
				db.close()
				return
			}
			key = generatedKey
		} else {
			if let keyData = loadFromKeychain(key: "secureStoreDatabaseKey") {
				key = String(decoding: keyData, as: UTF8.self)
			} else {
				guard let generatedKey = generateDatabaseKey() else {
					db.close()
					return
				}
				key = generatedKey
			}
		}
		let dbhandle = OpaquePointer(db.sqliteHandle)
		guard sqlite3_key(dbhandle, key, Int32(key.count)) == SQLITE_OK else {
			logError(message: "Unable to set Key")
			db.close()
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
			removeDatabase()
		}
	}

	/// Checks if is the inital Setup of the Database
	/// This determins if a new Key should be generated or not
	private func checkInitalSetup() -> Bool {
		do {
			let query = "SELECT count(*) FROM sqlite_master;;"
			 let result = try db.executeQuery(query, values: [])
			result.close()
			return true
		} catch {
			return false
		}
	}

	///Open Database Connection, set the Key and check if the Key/Value Table already exits.
	/// This retries the init steps, in case there was an issue
	private func openDbIfNeeded() {
		if !db.isOpen {
			db.open()
			initDatabase()
		}
	}

	/// - returns: `Data` if the key/value pair in the DB, `nil` otherwise
	private func getData(for key: String) -> Data? {
		openDbIfNeeded()

		do {
			let query = "SELECT value FROM kv WHERE key = ?;"
			let result = try db.executeQuery(query, values: [key])
			var resultData: Data?
			while result.next() {
				// We use dataNoCopy() as data() returns nil even though there is empty Data
				// This is unexpected, as empty Data of course does not mean nil
				guard let data = result.dataNoCopy(forColumn: "value") else {
					return nil
				}
				resultData = data
			}
			result.close()
			return resultData
		} catch {
			logError(message: "Failed to retrieve value from K/V SQLite store: \(error.localizedDescription)")
			return nil
		}
	}

	/// Sets or overwrites the value for a given key
	/// - attention: Passing `nil` to the data param causes the key/value pair to be deleted from the DB
	private func setData(_ data: Data?, for key: String) {
		openDbIfNeeded()
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

	/// Removes all key/value pairs from the Store
	func clearAll() {
		openDbIfNeeded()

		let sqlStmt = """
		PRAGMA journal_mode=OFF;
		DROP TABLE kv;
		VACUUM;
		"""
		 db.executeStatements(sqlStmt)
		removeDatabase()
	}

	/// Removes the Database File to clear everything
	private func removeDatabase() {
		db.close()
		do {
			guard let url: URL = db.databaseURL else {
				logError(message: "DatabaseURL not found in db")
				return
			}
			try FileManager.default.removeItem(at: url)
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
		let deleteStmt = "DELETE FROM kv WHERE key NOT IN('developerSubmissionBaseURLOverride','developerDistributionBaseURLOverride','developerVerificationBaseURLOverride');"
		do {
			try db.executeUpdate(deleteStmt, values: [])
			try db.executeUpdate("VACUUM", values: [])
			log(message: "Flushed SecureStore", level: .info)
		} catch {
			logError(message: "Failed to delete key from K/V SQLite store: \(error.localizedDescription)")
		}
		return
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

/// Keychain Extension for storing and loading the Database Key in the Keychain
extension SQLiteKeyValueStore {
	func savetoKeychain(key: String, data: Data) -> OSStatus {
		let query = [
			kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: key,
			kSecValueData as String: data ] as [String: Any]

		SecItemDelete(query as CFDictionary)
		return SecItemAdd(query as CFDictionary, nil)
	}

	func loadFromKeychain(key: String) -> Data? {
		let query = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: kCFBooleanTrue as Any,
			kSecMatchLimit as String: kSecMatchLimitOne
			] as [String: Any]
		
		var dataTypeRef: AnyObject?
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
		if status == noErr {
			return dataTypeRef as? Data ?? nil
		} else {
			return nil
		}
	}

	func generateDatabaseKey() -> String? {
		var bytes = [UInt8](repeating: 0, count: 32)
		let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		guard result == errSecSuccess else {
			logError(message: "Error creating random bytes.")
			return nil
		}
		let key = "x'\(Data(bytes).hexEncodedString())'"
		if savetoKeychain(key: "secureStoreDatabaseKey", data: Data(key.utf8)) != noErr {
			logError(message: "Unable to save Key to Keychain")
			db.close()
			return nil
		}
		return key
	}
}

/// Extensions for Hexencoding when generating key
extension Data {
	struct HexEncodingOptions: OptionSet {
		let rawValue: Int
		static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}

	func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = "%02hhX"
		return map { String(format: format, $0) }.joined()
	}
}
