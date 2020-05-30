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

class SQLiteKeyValueStore {
	private let db: FMDatabase

	/// - parameter url: URL on disk where the FMDB should be initialized
	init(with url: URL) {
		let sqlStmt = """
		CREATE TABLE IF NOT EXISTS kv (
		    key TEXT UNIQUE,
		    value BLOB
		);
		"""

		db = FMDatabase(url: url)
		db.open()
		db.executeStatements(sqlStmt)
	}

	deinit {
		db.close()
	}

	private func openDbIfNeeded() {
		if !db.isOpen {
			db.open()
		}
	}

	private func getData(for key: String) -> Data? {
		openDbIfNeeded()

		do {
			let query = "SELECT value FROM kv WHERE key = ?;"
			let result = try db.executeQuery(query, values: [key])
			var resultData = Data()
			while result.next() {
				guard let data = result.data(forColumn: "value") else {
					return nil
				}
				resultData = data
			}

			result.close()

			return resultData
		} catch {
			appLogger.error(message: "Failed to retrieve value from K/V SQLite store: \(error.localizedDescription)")
			return nil
		}
	}

	private func setData(_ data: Data?, for key: String) {
		openDbIfNeeded()
		guard let data = data else {
			return
		}

		/// Insert the key/value pair if it isn't already in the Database, otherwise Update the value
		let upsertStmt = "INSERT INTO kv(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value = ?"
		do {
			try db.executeUpdate(upsertStmt, values: [key, data, data])
		} catch {
			appLogger.error(message: "Failed to insert key/V pair into K/V SQLite store: \(error.localizedDescription)")
		}
	}

	func clearAll() {
		openDbIfNeeded()
		let deleteStmt = "DELETE FROM kv;"
		do {
			try db.executeUpdate(deleteStmt, values: [])
			try db.executeUpdate("VACUUM", values: [])
			appLogger.info(message: "Cleared SecureStore")
		} catch {
			appLogger.error(message: "Failed to delete key from K/V SQLite store: \(error.localizedDescription)")
		}
		return
	}

	func flush() {
		openDbIfNeeded()
		let deleteStmt = "DELETE FROM kv WHERE key NOT IN('developerSubmissionBaseURLOverride','developerDistributionBaseURLOverride','developerVerificationBaseURLOverride');"
		do {
			try db.executeUpdate(deleteStmt, values: [])
			try db.executeUpdate("VACUUM", values: [])
			appLogger.info(message: "Flushed SecureStore")
		} catch {
			appLogger.error(message: "Failed to delete key from K/V SQLite store: \(error.localizedDescription)")
		}
		return
	}

	subscript(key: String) -> Data? {
		get {
			getData(for: key)
		}
		set {
			setData(newValue, for: key)
		}
	}

	/// - important: Assumes data was encoded with a `JSONEncoder`!
	subscript<Model: Codable>(key: String) -> Model? {
		get {
			guard let data = getData(for: key) else {
				return nil
			}
			// TODO: Error handling
			return try? JSONDecoder().decode(Model.self, from: data)
		}
		set {
			do {
				let encoded = try JSONEncoder().encode(newValue)
				setData(encoded, for: key)
			} catch {
				appLogger.error(message: "Error when encoding value for inserting into K/V SQLite store: \(error.localizedDescription)")
			}
		}
	}
}
