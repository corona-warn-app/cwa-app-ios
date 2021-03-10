////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
import OpenCombine
@testable import ENA

class EventStoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

	private func makeDatabaseQueue() -> FMDatabaseQueue {
		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}
		return databaseQueue
	}

	private func makeStore(
		with databaseQueue: FMDatabaseQueue,
		dateProvider: DateProviding = DateProvider(),
		schema: StoreSchemaProtocol? = nil,
		migrator: SerialMigratorProtocol? = nil
	) -> EventStore {

		let _schema: StoreSchemaProtocol
		if let schema = schema {
			_schema = schema
		} else {
			_schema = EventStoreSchemaV1(databaseQueue: databaseQueue)
		}

		let _migrator: SerialMigratorProtocol
		if let migrator = migrator {
			_migrator = migrator
		} else {
			_migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 1, migrations: [])
		}

		guard let store = EventStore(
			databaseQueue: databaseQueue,
			schema: _schema,
			key: "Dummy",
			migrator: _migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}
}
