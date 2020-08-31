//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
import FMDB
@testable import ENA

class MigrationStub: Migration {

	private let migration: () -> Void

	init(migration: @escaping () -> Void) {
		self.migration = migration
	}

	func execute(completed: (Bool) -> Void) {
		migration()
		completed(true)
	}
}

class SerialMigratorTests: XCTestCase {

	func testSerialMigratorWithNoMigrations() {
		let database = makeDataBase()
		insertDummyData(to: database)

		let serialMigrator = SerialMigrator(latestVersion: 0, database: database, migrations: [])
		serialMigrator.migrate()

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 2)
	}

	func testSerialMigratorWithOneMigration() {
		let database = makeDataBase()
		insertDummyData(to: database)

		let migrationExpectation = expectation(description: "Migration was called.")

		let migration = MigrationStub { [weak self] in
			self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN")
			migrationExpectation.fulfill()
		}

		let serialMigrator = SerialMigrator(latestVersion: 1, database: database, migrations: [migration])
		serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 3)
	}

	func testSerialMigratorWithSeveralMigrations() {
		let database = makeDataBase()
		insertDummyData(to: database)

		let migrationExpectation = expectation(description: "Migration was called.")
		migrationExpectation.expectedFulfillmentCount = 2
		migrationExpectation.assertForOverFulfill = true

		let migration0To1 = MigrationStub { [weak self] in
			self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_1")
			migrationExpectation.fulfill()
		}

		let migration1To2 = MigrationStub { [weak self] in
			self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_2")
			migrationExpectation.fulfill()
		}

		let serialMigrator = SerialMigrator(latestVersion: 2, database: database, migrations: [migration0To1, migration1To2])
		serialMigrator.migrate()

		waitForExpectations(timeout: 3.0)

		XCTAssertEqual(database.numberOfRows(for: "Z_SOME_TABLE"), 1)
		XCTAssertEqual(database.numberOfColumns(for: "Z_SOME_TABLE"), 4)
	}

	func testSerialMigratorWithSeveralMigrationsExecutingOnlyCurrentMigration() {
		let database = makeDataBase()
		insertDummyData(to: database)
		database.userVersion = 1

		let migration0To1 = MigrationStub {
			XCTFail("This migration should not be executed, because userVersion is 1.")
		}

		let migrationExpectation = expectation(description: "Migration was called.")

		let migration1To2 = MigrationStub { [weak self] in
			self?.addDummyColumn(to: database, name: "Z_SOME_COLUMN_1")
			migrationExpectation.fulfill()
		}

		let serialMigrator = SerialMigrator(latestVersion: 2, database: database, migrations: [migration0To1, migration1To2])
		serialMigrator.migrate()

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
