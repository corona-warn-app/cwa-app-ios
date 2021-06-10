////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryMigration4To5Tests: CWATestCase {

	func test_WHEN_migrationFrom4To5_THEN_OldAndNewTablesArePresent() throws {

		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		// Create V4 schema.
		let schemaV4 = ContactDiaryStoreSchemaV4(databaseQueue: databaseQueue)

		let schemaV4Result = schemaV4.create()
		if case let .failure(error) = schemaV4Result {
			XCTFail("Error not expected: \(error)")
		}

		// Migrate to V5 schema.
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: 5,
			migrations: [ContactDiaryMigration4To5(databaseQueue: databaseQueue)]
		)
		try migrator.migrate()

		databaseQueue.inDatabase { database in
			XCTAssertTrue(database.tableExists("ContactPerson"))
			XCTAssertTrue(database.tableExists("Location"))
			XCTAssertTrue(database.tableExists("ContactPersonEncounter"))
			XCTAssertTrue(database.tableExists("LocationVisit"))
			XCTAssertTrue(database.tableExists("CoronaTest"))

			XCTAssertEqual(database.userVersion, 5)
		}
	}
}
