////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration2To3: Migration {

	private let databaseQueue: FMDatabaseQueue
	private var database: FMDatabase?
	private var error: Error?
	
	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol Migration

	let version = 3

	func execute() throws {
		var error: Error?

		databaseQueue.inDatabase { database in
			let sql = """
				BEGIN TRANSACTION;

				-- Add phoneNumber, emailAddress columns to ContactPerson
				ALTER TABLE ContactPerson
					ADD phoneNumber TEXT NULL;
				ALTER TABLE ContactPerson
					ADD emailAddress TEXT NULL;

				-- add phoneNumber, emailAddress columns to Location
				ALTER TABLE Location
					ADD phoneNumber TEXT NULL;
				ALTER TABLE Location
					ADD emailAddress TEXT NULL;

				-- add duration, maskSituation, setting columns to ContactPersonEncounter
				ALTER TABLE ContactPersonEncounter
					ADD duration INTEGER NULL;
				ALTER TABLE ContactPersonEncounter
					ADD maskSituation INTEGER NULL;
				ALTER TABLE ContactPersonEncounter
					ADD setting INTEGER NULL;

				-- add durationInMinutes, circumstances columns to LocationVisit
				ALTER TABLE LocationVisit
					ADD durationInMinutes NULL;
				ALTER TABLE LocationVisit
					ADD circumstances TEXT NULL;

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
