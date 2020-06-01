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
	private var db: SQLiteDBBacisWrapper?

	/// - parameter url: URL on disk where the FMDB should be initialized
	init(with url: URL) {
		let sqlStmt = """
		CREATE TABLE IF NOT EXISTS kv (
		    key TEXT UNIQUE,
		    value BLOB
		);
		"""

		db = nil
		var key: String
		if let keyData = loadFromKeychain(key: "dbKey") {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			key = UUID().uuidString
			if savetoKeychain(key: "dbKey", data: Data(key.utf8)) == noErr {
				logError(message: "Unable to open save Key to Keychain")
			}
		}
		do {
			db = try SQLiteDBBacisWrapper.open(path: url.absoluteString, secret: key)
			log(message: "Successfully opened connection to database.", level: .info)
			try db?.createTable(sql: sqlStmt)
		} catch {
			logError(message: "Unable to open Database")
			return
		}
	}

	/// - returns: `Data` if the key/value pair in the DB, `nil` otherwise
	private func getData(for key: String) -> Data? {
		return db?.getValue(key: key)
	}

	/// Sets or overwrites the value for a given key
	/// - attention: Passing `nil` to the data param causes the key/value pair to be deleted from the DB
	private func setData(_ data: Data?, for key: String) {
		guard let data = data else {
			db?.deleteKey(key)
			return
		}
		do {
			try db?.insertKeyValue(key: key, data: data)
		} catch {
			return
		}
	}

	/// Removes all key/value pairs from the Store
	func clearAll() {
		db?.clearAll()
		db?.vacuum()
	}

	/// Removes most key/value pairs.
	///
	/// Keys whose values are not removed:
	/// - `developerSubmissionBaseURLOverride`
	/// - `developerDistributionBaseURLOverride`
	/// - `developerVerificationBaseURLOverride`
	func flush() {
		db?.flush()
		db?.vacuum()
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
			kSecReturnData as String: kCFBooleanTrue!,
			kSecMatchLimit as String: kSecMatchLimitOne] as [String: Any]

		var dataTypeRef: AnyObject?
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
		if status == noErr {
			return dataTypeRef as? Data ?? nil
		} else {
			return nil
		}
	}
}
