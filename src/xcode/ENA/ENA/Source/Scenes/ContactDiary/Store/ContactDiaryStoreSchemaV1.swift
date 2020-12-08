////
// 🦠 Corona-Warn-App
//

import FMDB

class ContactDiaryStoreSchemaV1 {

	private let database: FMDatabase
	private let queue: DispatchQueue

	init(
		database: FMDatabase,
		queue: DispatchQueue
	) {
		self.database = database
		self.queue = queue
	}

	func create() -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			let sql = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;

				CREATE TABLE IF NOT EXISTS ContactPerson (
					id INTEGER PRIMARY KEY,
					name STRING NOT NULL
				);

				CREATE TABLE IF NOT EXISTS Location (
					id INTEGER PRIMARY KEY,
					name STRING NOT NULL
				);

				CREATE TABLE IF NOT EXISTS ContactPersonEncounter (
					id INTEGER PRIMARY KEY,
					date STRING NOT NULL,
					contactPersonId INTEGER NOT NULL,
					FOREIGN KEY(contactPersonId) REFERENCES ContactPerson(id)
				);

				CREATE TABLE IF NOT EXISTS LocationVisit (
					id INTEGER PRIMARY KEY,
					date STRING NOT NULL,
					locationId INTEGER NOT NULL,
					FOREIGN KEY(locationId) REFERENCES Location(id)
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
