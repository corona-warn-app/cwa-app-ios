////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration2To3: Migration {

	private let databaseQueue: FMDatabaseQueue
	private var error: Error?
	private let maxTextLength = 250

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol Migration

	let version = 3

	func execute() throws {
		var error: Error?

		databaseQueue.inDatabase { database in

			// There was a bug during migration 1 to 2. Due to this bug, the migration was not triggered, but the userVersion was set to 2. Therfore we need to do this migration again, to fix the datatypes.

			var finalSQL: String?
			let tableNames = ["ContactPerson", "Location"]

			for tableName in tableNames {
				let queryResult = database.prepare("PRAGMA table_info(" + tableName + ")" )

				while queryResult.next() {
					let name = queryResult.string(forColumn: "name")
					let type = queryResult.string(forColumn: "type")

					// do migration for contact diary tables if the type of the Column "name" is "STRING"
					if name == "name" && type == "STRING" {
						finalSQL = """
						PRAGMA foreign_keys=OFF;

						CREATE TABLE tmp (
						id INTEGER PRIMARY KEY,
						name TEXT NOT NULL CHECK (LENGTH(name) <= 250)
						);
						INSERT INTO tmp (id, name)
						SELECT id, name
						FROM \(tableName);
						DROP TABLE \(tableName);
						ALTER TABLE tmp RENAME TO \(tableName);

						PRAGMA foreign_keys=ON;
						"""

						break
					}
				}

				queryResult.close()
				guard let sql = finalSQL, database.executeStatements(sql) else {
					error = MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
					return
				}
			}

			// This is the real 2 to 3 migration. Its adding new columns for the new contact diary features.

			let sql = """
				BEGIN TRANSACTION;

				-- Add phoneNumber, emailAddress columns to ContactPerson
				ALTER TABLE ContactPerson
					ADD phoneNumber TEXT NULL CHECK (LENGTH(phoneNumber) <= \(maxTextLength));
				ALTER TABLE ContactPerson
					ADD emailAddress TEXT NULL CHECK (LENGTH(emailAddress) <= \(maxTextLength));

				-- add phoneNumber, emailAddress columns to Location
				ALTER TABLE Location
					ADD phoneNumber TEXT NULL CHECK (LENGTH(phoneNumber) <= \(maxTextLength));
				ALTER TABLE Location
					ADD emailAddress TEXT NULL CHECK (LENGTH(emailAddress) <= \(maxTextLength));

				-- add duration, maskSituation, setting, circumstances columns to ContactPersonEncounter
				ALTER TABLE ContactPersonEncounter
					ADD duration INTEGER NULL;
				ALTER TABLE ContactPersonEncounter
					ADD maskSituation INTEGER NULL;
				ALTER TABLE ContactPersonEncounter
					ADD setting INTEGER NULL;
				ALTER TABLE ContactPersonEncounter
					ADD circumstances TEXT NULL CHECK (LENGTH(circumstances) <= \(maxTextLength));

				-- add durationInMinutes, circumstances columns to LocationVisit
				ALTER TABLE LocationVisit
					ADD durationInMinutes NULL;
				ALTER TABLE LocationVisit
					ADD circumstances TEXT NULL CHECK (LENGTH(circumstances) <= \(maxTextLength));

				COMMIT;
			"""

			guard database.executeStatements(sql) else {
				error = MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
				return
			}

			database.userVersion = UInt32(version)
		}
		
		if let error = error {
			throw error
		}
	}
}
