////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryStoreSchemaV1Tests: XCTestCase {

	func test_When_createIsCalled_Then_AllTablesAreCreated() {
		let database = FMDatabase.inMemory()
		database.open()

		let queue = DispatchQueue(label: "ContactDiaryStoreSchemaV1TestsQueue")
		let schema = ContactDiaryStoreSchemaV1(database: database, queue: queue)

		let result = schema.create()

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		XCTAssertTrue(database.tableExists("ContactPerson"))
		XCTAssertTrue(database.tableExists("Location"))
		XCTAssertTrue(database.tableExists("ContactPersonEncounter"))
		XCTAssertTrue(database.tableExists("LocationVisit"))
	}
}
