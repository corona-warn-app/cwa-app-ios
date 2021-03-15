////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration3To4: Migration {

	private let databaseQueue: FMDatabaseQueue
	private var error: Error?
	private let maxTextLength = 250

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol Migration

	let version = 4

	func execute() throws {
		var error: Error?

		databaseQueue.inDatabase { database in

			let sql = """
				BEGIN TRANSACTION;

				ALTER TABLE Location
					ADD traceLocationGUID TEXT NULL;

				ALTER TABLE LocationVisit
					ADD checkinId INTEGER NULL;

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
