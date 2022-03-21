//
// 🦠 Corona-Warn-App
//

import FMDB

final class Migration2To3: Migration {

	private let database: FMDatabase

	// MARK: - Init

	init(database: FMDatabase) {
		self.database = database
	}

	// MARK: - Protocol Migration

	let version = 3

	func execute() throws {
		let sql = """
			BEGIN TRANSACTION;

			-- add column
			ALTER TABLE Z_DOWNLOADED_PACKAGE
			ADD Z_CHECKED_FOR_EXPOSURES INTEGER DEFAULT 0;

			COMMIT;
		"""

		guard database.executeStatements(sql) else {
			throw MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
		}
	}
}
