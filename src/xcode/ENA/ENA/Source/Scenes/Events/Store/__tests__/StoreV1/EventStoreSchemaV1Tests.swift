////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class EventStoreSchemaV1Tests: XCTestCase {

	func test_When_createIsCalled_Then_AllTablesAreCreated() {
		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		let schema = EventStoreSchemaV1(databaseQueue: databaseQueue)

		let result = schema.create()

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		databaseQueue.inDatabase { database in
			XCTAssertTrue(database.tableExists("Checkin"))
			XCTAssertTrue(database.tableExists("TraceLocation"))
			XCTAssertTrue(database.tableExists("TraceTimeIntervalMatch"))
			XCTAssertTrue(database.tableExists("TraceWarningPackageMetadata"))

			XCTAssertEqual(database.userVersion, 1)
		}
	}
}
