//
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

final class SerialMigratorTests: XCTestCase {

	func testSerialMigratorWithNoMigrations() throws {
		let database = makeDataBase()
		insertDummyData(to: database)

		let serialMigrator = SerialMigrator(latestVersion: 0, database: database, migrations: [])
		try serialMigrator.migrate()

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 2)
	}

	func testSerialMigratorWithOneMigration() throws {
		let database = makeDataBase()
		insertDummyData(to: database)

		let migrationExpectation = expectation(description: "Migration was called.")

		let migration = MigrationStub(
			version: 1,
			migration: { [weak self] in
				self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN")
				migrationExpectation.fulfill()
			}
		)

		let serialMigrator = SerialMigrator(latestVersion: 1, database: database, migrations: [migration])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 3)
	}

	func testSerialMigratorWithSeveralMigrations() throws {
		let database = makeDataBase()
		insertDummyData(to: database)

		let migrationExpectation = expectation(description: "Migration was called.")
		migrationExpectation.expectedFulfillmentCount = 2
		migrationExpectation.assertForOverFulfill = true

		let migration0To1 = MigrationStub(
			version: 1,
			migration: { [weak self] in
				self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_1")
				migrationExpectation.fulfill()
			}
		)

		let migration1To2 = MigrationStub(
			version: 2,
			migration: { [weak self] in
				self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_2")
				migrationExpectation.fulfill()
			}
		)

		let serialMigrator = SerialMigrator(latestVersion: 2, database: database, migrations: [migration0To1, migration1To2])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 4)
	}

	func testSerialMigratorWithSeveralMigrationsExecutingOnlyCurrentMigration() throws {
		let database = makeDataBase()
		insertDummyData(to: database)
		database.userVersion = 1

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
				self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_1")
				migrationExpectation.fulfill()
			}
		)


		let serialMigrator = SerialMigrator(latestVersion: 2, database: database, migrations: [migration0To1, migration1To2])
		try serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 3)
	}

	func makeDataBase() -> FMDatabase {
		let database = FMDatabase(path: "file::memory:")
		database.open()
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
		return database
	}

	func insertDummyData(to database: FMDatabase) {
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

	func addDummyColumn(to database: FMDatabase, name: String) {
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
