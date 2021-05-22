////
// 🦠 Corona-Warn-App
//

import FMDB
import CWASQLite

class ContactDiaryStoreSchemaV4: StoreSchemaProtocol {

	// MARK: - Init

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Public

	@discardableResult
	func create() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult = .success(())

		databaseQueue.inDatabase { database in
			let sql = """
				CREATE TABLE IF NOT EXISTS ContactPerson (
					id INTEGER PRIMARY KEY,
					name TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					phoneNumber TEXT CHECK (LENGTH(phoneNumber) <= \(maxTextLength)),
					emailAddress TEXT CHECK (LENGTH(emailAddress) <= \(maxTextLength))
				);

				CREATE TABLE IF NOT EXISTS Location (
					id INTEGER PRIMARY KEY,
					name TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					phoneNumber TEXT CHECK (LENGTH(phoneNumber) <= \(maxTextLength)),
					emailAddress TEXT CHECK (LENGTH(emailAddress) <= \(maxTextLength)),
					traceLocationId BLOB
				);

				CREATE TABLE IF NOT EXISTS ContactPersonEncounter (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					duration INTEGER,
					maskSituation INTEGER,
					setting INTEGER,
					circumstances TEXT CHECK (LENGTH(circumstances) <= \(maxTextLength)),
					contactPersonId INTEGER NOT NULL,
					FOREIGN KEY(contactPersonId) REFERENCES ContactPerson(id) ON DELETE CASCADE
				);

				CREATE TABLE IF NOT EXISTS LocationVisit (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					durationInMinutes INTEGER,
					circumstances TEXT CHECK (LENGTH(circumstances) <= \(maxTextLength)),
					locationId INTEGER NOT NULL,
					checkinId INTEGER,
					FOREIGN KEY(locationId) REFERENCES Location(id) ON DELETE CASCADE
				);
			"""

			guard database.executeStatements(sql) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				let error = SecureSQLStoreError.database(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				result = .failure(error)
				return
			}

			database.userVersion = 4
			result = .success(())
		}

		return result
	}

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue
	private let maxTextLength = 250

}
