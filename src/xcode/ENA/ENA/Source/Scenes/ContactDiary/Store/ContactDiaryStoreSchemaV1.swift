////
// 🦠 Corona-Warn-App
//

import FMDB
import CWASQLite

class ContactDiaryStoreSchemaV1 {

	private let database: FMDatabase
	private let queue: DispatchQueue
	private let key: String

	init(
		database: FMDatabase,
		queue: DispatchQueue,
		key: String
	) {
		self.database = database
		self.queue = queue
		self.key = key
	}

	func create() -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			let dbhandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbhandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("[ContactDiaryStore] Unable to set Key for encryption.", log: .localData)
				return .failure(SQLiteErrorCode.unknown)
			}

			let sql = """
				CREATE TABLE IF NOT EXISTS ContactPerson (
					id INTEGER PRIMARY KEY,
					name STRING NOT NULL CHECK (LENGTH(name) <= 250)
				);

				CREATE TABLE IF NOT EXISTS Location (
					id INTEGER PRIMARY KEY,
					name STRING NOT NULL CHECK (LENGTH(name) <= 250)
				);

				CREATE TABLE IF NOT EXISTS ContactPersonEncounter (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					contactPersonId INTEGER NOT NULL,
					FOREIGN KEY(contactPersonId) REFERENCES ContactPerson(id) ON DELETE CASCADE
				);

				CREATE TABLE IF NOT EXISTS LocationVisit (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					locationId INTEGER NOT NULL,
					FOREIGN KEY(locationId) REFERENCES Location(id) ON DELETE CASCADE
				);
			"""

			guard self.database.executeStatements(sql) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			self.database.userVersion = 1
			return .success(())
		}
	}
}
