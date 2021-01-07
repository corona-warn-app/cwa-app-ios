////
// 🦠 Corona-Warn-App
//

import FMDB
import CWASQLite


protocol ContactDiarySchemaProtocol {
	func create() -> Result<Void, SQLiteErrorCode>
}

class ContactDiaryStoreSchemaV2: ContactDiarySchemaProtocol {

	// MARK: - Init

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Public

	@discardableResult
	func create() -> Result<Void, SQLiteErrorCode> {
		var result: Result<Void, SQLiteErrorCode> = .success(())

		databaseQueue.inDatabase { database in
			let sql = """
				CREATE TABLE IF NOT EXISTS ContactPerson (
					id INTEGER PRIMARY KEY,
					name TEXT NOT NULL CHECK (LENGTH(name) <= 250)
				);

				CREATE TABLE IF NOT EXISTS Location (
					id INTEGER PRIMARY KEY,
					name TEXT NOT NULL CHECK (LENGTH(name) <= 250)
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

			guard database.executeStatements(sql) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			database.userVersion = 2
			result = .success(())
		}

		return result
	}

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue

}
