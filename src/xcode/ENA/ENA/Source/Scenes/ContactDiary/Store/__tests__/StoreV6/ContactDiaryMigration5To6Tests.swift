////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryMigration5To6Tests: CWATestCase {

	func test_WHEN_migrationFrom5To6_THEN_OldAndNewTablesArePresent() throws {

		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		// Create V5 schema.
		let schemaV5 = ContactDiaryStoreSchemaV5(databaseQueue: databaseQueue)

		let schemaV5Result = schemaV5.create()
		if case let .failure(error) = schemaV5Result {
			XCTFail("Error not expected: \(error)")
		}

		// Migrate to V6 schema.
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: 6,
			migrations: [ContactDiaryMigration5To6(databaseQueue: databaseQueue)]
		)
		try migrator.migrate()

		databaseQueue.inDatabase { database in
			XCTAssertTrue(database.tableExists("ContactPerson"))
			XCTAssertTrue(database.tableExists("Location"))
			XCTAssertTrue(database.tableExists("ContactPersonEncounter"))
			XCTAssertTrue(database.tableExists("LocationVisit"))
			XCTAssertTrue(database.tableExists("CoronaTest"))
			XCTAssertTrue(database.tableExists("Submission"))

			XCTAssertEqual(database.userVersion, 6)
		}
	}
}
