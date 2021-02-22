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

		// There was a bug during migration 1 to 2. Due to this bug, the migration was not triggered, but the userVersion was set to 2. Therfore we need to do this migration again, to fix the datatypes.

		let migration1to2 = ContactDiaryMigration1To2 (databaseQueue: databaseQueue)
		try migration1to2.execute()

		// This is the real 2 to 3 migration. Its adding new columns for the new contact diary features.

		databaseQueue.inDatabase { database in

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
