////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration4To5: Migration {

	private let databaseQueue: FMDatabaseQueue
	private var error: Error?

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol Migration

	let version = 5

	func execute() throws {
		var error: Error?

		databaseQueue.inDatabase { database in

			let sql = """
				BEGIN TRANSACTION;

				CREATE TABLE IF NOT EXISTS CoronaTest (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					testType INTEGER NOT NULL,
					testResult INTEGER NOT NULL
				);

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
