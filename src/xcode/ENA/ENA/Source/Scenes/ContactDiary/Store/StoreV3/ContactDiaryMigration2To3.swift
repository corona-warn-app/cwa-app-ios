////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration2To3: Migration {

	// MARK: - Init

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol Migration

	let version = 3

	func execute() throws {
		databaseQueue.inDatabase { [weak self] database in
			guard let self = self else {
				error = MigrationError.failed(from: 2, to: 3)
				return
			}
			self.database = database
			let sqlQuery = """
				CREATE TABLE IF NOT EXISTS RiskLevelPerDate (
					id INTEGER PRIMARY KEY,
					date TEXT NOT NULL,
					riskLevel INTEGER NOT NULL
				);
			"""

			guard database.executeStatements(sqlQuery) else {
				error = MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
				return
			}
		}

		if let error = error {
			throw error
		}
	}

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue
	private var database: FMDatabase?
	private var error: Error?
	
}
