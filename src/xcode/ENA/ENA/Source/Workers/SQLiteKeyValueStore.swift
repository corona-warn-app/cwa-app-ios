//
// 🦠 Corona-Warn-App
//

import FMDB
import Foundation
import CWASQLite

enum SQLiteStoreError: Error {
	case databaseInitFailure
	case readError(_ message: String? = nil)
	case writeError(_ message: String? = nil)
}

/// Basic SQLite Key/Value store with Keys as `TEXT` and Values stored as `BLOB`
final class SQLiteKeyValueStore {
	private let databaseQueue: FMDatabaseQueue?
	private let directoryURL: URL


	/// - parameter url: URL on disk where the FMDB should be initialized
	/// If any part of the init fails no Datbase will be created
	/// If the Database can't be accessed with the key the currentFile will be reset

	init(with directoryURL: URL, key: String) throws {
		self.directoryURL = directoryURL
		var fileURL = directoryURL
		if directoryURL.absoluteString != ":memory:" {
			fileURL = fileURL.appendingPathComponent("secureStore.sqlite")
		}
		databaseQueue = FMDatabaseQueue(url: fileURL)
		guard initDatabase(with: key) else {
			throw SQLiteStoreError.databaseInitFailure
		}
	}

	deinit {
		closeDbIfNeeded()
	}

	// MARK: - Internal database modifications

	/// Generates or Loads Database Key
	/// Creates the K/V Database if it is not already there
	private func initDatabase(with key: String) -> Bool {

		var isSuccess = true
		databaseQueue?.inDatabase { db in
			let dbhandle = OpaquePointer(db.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbhandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("Unable to set Key", log: .localData)
				isSuccess = false
				return
			}
			let sqlStmt = """
			PRAGMA auto_vacuum=2;

			CREATE TABLE IF NOT EXISTS kv (
				key TEXT UNIQUE,
				value BLOB
			);
			"""

			isSuccess = db.executeStatements(sqlStmt)
		}
		return isSuccess
	}

	/// Open Database Connection, set the Key and check if the Key/Value Table already exits.
	/// This retries the init steps, in case there was an issue
	private func openDbIfNeeded() {
		databaseQueue?.inDatabase { db in
			if !db.isOpen {
				db.open()
			}
		}
	}


	private func closeDbIfNeeded() {
		databaseQueue?.inDatabase { db in
			if db.isOpen {
				db.close()
			}
		}
	}

	/// - returns: `Data` if the key/value pair in the DB, `nil` otherwise
	private func getData(for key: String) throws -> Data? {
		openDbIfNeeded()

		var dataToReturn: Data?
		// hack to pass potential errors from the closure back to the local scope
		var dbError: NSError?
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
				let message = "Failed to retrieve value from K/V SQLite store: \(error.localizedDescription)"
				Log.error(message, log: .localData)
				dbError = SQLiteStoreError.readError(message) as NSError
			}
		}
		if let error = dbError as? SQLiteStoreError {
			throw error
		}
		return dataToReturn
	}

	/// Sets or overwrites the value for a given key
	/// - attention: Passing `nil` to the data param causes the key/value pair to be deleted from the DB
	private func setData(_ data: Data?, for key: String) throws {
		openDbIfNeeded()

		// hack to pass potential errors from the closure back to the local scope
		var dbError: NSError?
		databaseQueue?.inDatabase { db in
			guard let data = data else {
				let deleteStmt = "DELETE FROM kv WHERE key = ?;"
				do {
					try db.executeUpdate(deleteStmt, values: [key])
					try db.executeUpdate("VACUUM", values: [])
				} catch {
					let message = "Failed to delete key from K/V SQLite store: \(error.localizedDescription)"
					Log.error(message, log: .localData)
					dbError = SQLiteStoreError.writeError(message) as NSError
				}
				return
			}

			/// Insert the key/value pair if it isn't already in the Database, otherwise Update the value
			let upsertStmt = "INSERT INTO kv(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value = ?"
			do {
				try db.executeUpdate(upsertStmt, values: [key, data, data])
			} catch {
				let message = "Failed to insert key/V pair into K/V SQLite store: \(error.localizedDescription)"
				Log.error(message, log: .localData)
				dbError = SQLiteStoreError.writeError(message) as NSError
			}
		}
		if let error = dbError as? SQLiteStoreError {
			throw error
		}
	}

	/// Removes all key/value pairs from the Store and creates a new database with a given key
	/// - Parameters The new database key/password. If the key is nil, the action is same as the `resetDatabase`
	func clearAll(key: String?) throws {
		try resetDatabase()
		guard let key = key else {
			return
		}
		guard initDatabase(with: key) else {
			throw SQLiteStoreError.databaseInitFailure
		}
	}

	/// Removes the Database File to clear everything
	private func resetDatabase() throws {
		closeDbIfNeeded()
		do {
			try FileManager.default.removeItem(at: directoryURL)
			try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
		} catch {
			Log.error("Failed to delete database file", log: .localData)
			throw error
		}
	}

	// MARK: - Public

	/// Removes most key/value pairs.
	///
	/// Keys whose values are not removed:
	/// - `developerSubmissionBaseURLOverride`
	/// - `developerDistributionBaseURLOverride`
	/// - `developerVerificationBaseURLOverride`
	func flush() throws {
		openDbIfNeeded()

		// hack to pass potential errors from the closure back to the local scope
		var dbError: NSError?
		databaseQueue?.inDatabase { db in
			let deleteStmt = "DELETE FROM kv WHERE key NOT IN('developerSubmissionBaseURLOverride','developerDistributionBaseURLOverride','developerVerificationBaseURLOverride');"
			do {
				try db.executeUpdate(deleteStmt, values: [])
				try db.executeUpdate("VACUUM", values: [])
				Log.info("Flushed SecureStore", log: .localData)
			} catch {
				let message = "Failed to delete key from K/V SQLite store: \(error.localizedDescription)"
				Log.error(message, log: .localData)
				dbError = SQLiteStoreError.writeError(message) as NSError
			}
		}
		if let error = dbError as? SQLiteStoreError {
			throw error
		}
	}

	/// - parameter key: key index to look in the DB for
	/// - returns: `Data` if the key/value pair is found (even if the value BLOB is empty), or nil if no value exists for the given key.
	subscript(key: String) -> Data? {
		get {
			do {
				return try getData(for: key)
			} catch {
				Log.error("Cant fetch data for key '\(key)'", log: .localData, error: error)
				return nil
			}
		}
		set {
			do {
				try setData(newValue, for: key)
			} catch {
				Log.error("Cant set data for key '\(key)'", log: .localData, error: error)
			}
		}
	}

	/// Convenience subscript to use with `Codable` types, uses JSON encoder/decoder with no additional configuration.
	/// - returns: Model decoded with a `JSONDecoder`, or `nil` if decoding fails.
	///
	/// - attention: Errors encountered during encoding with `JSONEncoder` silently fail (but are logged)!
	///	If encoding fails, fetching the value for that key will result in empty `Data`
	/// Model needs to wrapped into array for iOS 12.5: https://drewag.me/posts/2019/09/11/json-encoder-change-in-swift-5
	/// On installations that are already in use we have to fallback to the old way to get the data that is not wrapped inside an array
	subscript<Model: Codable>(key: String) -> Model? {
		get {
			guard let data = try? getData(for: key) else {
				return nil
			}
			do {
				let array = try JSONDecoder().decode(Array<Model>.self, from: data)
				if let value = array.first {
					return value
				}

			} catch {
				Log.error("Error when decoding value from K/V SQLite store: \(error.localizedDescription)", log: .localData)
			}
			return try? JSONDecoder().decode(Model.self, from: data) // Fallback for old installations
		}
		set {
			do {
				let encoded = try JSONEncoder().encode([newValue])
				try setData(encoded, for: key)
			} catch {
				Log.error("Error when encoding value for inserting into K/V SQLite store: \(error.localizedDescription)", log: .localData)
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
