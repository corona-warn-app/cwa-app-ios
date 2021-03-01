//
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

final class SerialDatabaseQueueMigratorTests: XCTestCase {

	func testSerialMigratorWithNoMigrations() throws {
		let databaseQueue = makeDatabaseQueue()
		insertDummyData(to: databaseQueue)

		let serialMigrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 0, migrations: [])
		try serialMigrator.migrate()

		databaseQueue.inDatabase { database in
			XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
			XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 2)
		}
	}

	func testSerialMigratorWithOneMigration() throws {
		let databaseQueue = makeDatabaseQueue()
		insertDummyData(to: databaseQueue)

		let migrationExpectation = expectation(description: "Migration was called.")

		let migration = MigrationStub(
			version: 1,
			migration: { [weak self] in
				self?.addDummyColumn(to: databaseQueue, name: "Z_SOME_COLUMN")
				migrationExpectation.fulfill()
			}
		)

		let serialMigrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 1, migrations: [migration])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		databaseQueue.inDatabase { database in
			XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
			XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 3)
		}
	}

	func testSerialMigratorWithSeveralMigrations() throws {
        let databaseQueue = makeDatabaseQueue()
        insertDummyData(to: databaseQueue)

		let migrationExpectation = expectation(description: "Migration was called.")
		migrationExpectation.expectedFulfillmentCount = 2
		migrationExpectation.assertForOverFulfill = true

		let migration0To1 = MigrationStub(
			version: 1,
			migration: { [weak self] in
				self?.addDummyColumn(to: databaseQueue, name: "Z_SOME_COLUMN_1")
				migrationExpectation.fulfill()
			}
		)

		let migration1To2 = MigrationStub(
			version: 2,
			migration: { [weak self] in
				self?.addDummyColumn(to: databaseQueue, name: "Z_SOME_COLUMN_2")
				migrationExpectation.fulfill()
			}
		)

        let serialMigrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 2, migrations: [migration0To1, migration1To2])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

        databaseQueue.inDatabase { database in
            XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
            XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 4)
        }
	}

	func testSerialMigratorWithSeveralMigrationsExecutingOnlyCurrentMigration() throws {
        let databaseQueue = makeDatabaseQueue()
        insertDummyData(to: databaseQueue)

        databaseQueue.inDatabase { database in
            database.userVersion = 1
        }

		let migration0To1 = MigrationStub(
			version: 1,
			migration: {
				XCTFail("This migration should not be executed, because userVersion is 1.")
			}
		)

		let migrationExpectation = expectation(description: "Migration was called.")

		let migration1To2 = MigrationStub(
			version: 2,
			migration: { [weak self] in
				self?.addDummyColumn(to: databaseQueue, name: "Z_SOME_COLUMN_1")
				migrationExpectation.fulfill()
			}
		)

        let serialMigrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 2, migrations: [migration0To1, migration1To2])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

        databaseQueue.inDatabase { database in
            XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
            XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 3)
        }
	}

	private func makeDatabaseQueue() -> FMDatabaseQueue {
		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		setupDataBase(on: databaseQueue)

		return databaseQueue
	}

	private func setupDataBase(on queue: FMDatabaseQueue) {
		queue.inDatabase { database in
			database.executeStatements(
			"""
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;

				CREATE TABLE IF NOT EXISTS
					Z_SOME_TABLE (
					Z_SOME_KEY INTEGER NOT NULL,
					Z_SOME_VALUE INTEGER NOT NULL,
					PRIMARY KEY (
						Z_SOME_KEY
					)
				);
			"""
			)
		}
	}

	private func insertDummyData(to queue: FMDatabaseQueue) {
		queue.inDatabase { database in
			let sql = """
				INSERT INTO Z_SOME_TABLE(
					Z_SOME_KEY,
					Z_SOME_VALUE
				)
				VALUES (
					:someKey,
					:someValue
				);
			"""
			let parameters: [String: Any] = [
				"someKey": 0,
				"someValue": 42
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	private func addDummyColumn(to queue: FMDatabaseQueue, name: String) {
		queue.inDatabase { database in
			let sql = """
				BEGIN TRANSACTION;

				ALTER TABLE Z_SOME_TABLE
				ADD \(name) INTEGER;

				UPDATE Z_SOME_TABLE
				SET \(name) = 42;

				COMMIT;
			"""
			database.executeStatements(sql)
		}
	}
}
