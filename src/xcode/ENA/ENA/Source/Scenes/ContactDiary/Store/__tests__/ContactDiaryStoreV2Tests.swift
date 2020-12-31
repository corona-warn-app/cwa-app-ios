////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
import Combine
@testable import ENA

class ContactDiaryStoreV2Tests: XCTestCase {

	func test_When_addZeroPrefixedLocation_Then_LocationIsPersistedCorrectly() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)
		let testString = "0043"
		
		let result = store.addLocation(name: testString)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, testString)
	}
	
	func test_When_addZeroPrefixedContactPerson_Then_LocationIsPersistedCorrectly() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)
		let testString = "HBF"

		let result = store.addContactPerson(name: testString)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonResult = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
			  let name = contactPersonResult.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, testString)
	}
	
	private func makeDatabaseQueue() -> FMDatabaseQueue {
		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}
		return databaseQueue
	}
	
	private func makeContactDiaryStore(with databaseQueue: FMDatabaseQueue, dateProvider: DateProviding = DateProvider()) -> ContactDiaryStoreV2 {
		let schema = ContactDiaryStoreSchemaV2(databaseQueue: databaseQueue)

		guard let store = ContactDiaryStoreV2(
			databaseQueue: databaseQueue,
			schema: schema,
			key: "Dummy",
			dateProvider: dateProvider,
			latestDBVersion: 2
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}
	
	private func fetchEntries(for table: String, with id: Int, from databaseQueue: FMDatabaseQueue) -> FMResultSet? {
		var result: FMResultSet?
		databaseQueue.inDatabase { database in
			let sql =
			"""
				SELECT
					*
				FROM
					\(table)
				WHERE
					id = '\(id)'
			;
			"""
			guard let queryResult = database.executeQuery(sql, withParameterDictionary: nil) else {
				return
			}
			guard queryResult.next() else {
				return
			}
			result = queryResult
		}

		return result
	}
}
