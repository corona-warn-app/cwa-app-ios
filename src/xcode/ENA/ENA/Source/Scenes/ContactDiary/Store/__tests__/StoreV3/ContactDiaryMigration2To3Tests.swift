////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryMigration2To3Tests: XCTestCase {

	func test_WHEN_migrationFrom2To3_THEN_NewColumsAreAdded_AND_OldDataIsNotDeleted() throws {

		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		// Create V2 schema.

		let schemaV2 = ContactDiaryStoreSchemaV2(databaseQueue: databaseQueue)

		let schemaV2Result = schemaV2.create()
		if case let .failure(error) = schemaV2Result {
			XCTFail("Error not expected: \(error)")
		}

		// Add data to V2 schema.

		addV2Data(to: databaseQueue)

		// Migrate to V3 schema.

		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: 3,
			migrations: [ContactDiaryMigration2To3(databaseQueue: databaseQueue)]
		)
		try migrator.migrate()

		// Check if the data is still valid after migration.

		checkV3Data(from: databaseQueue)
	}

	private func addV2Data(to databaseQueue: FMDatabaseQueue) {
		let person1Id = addContactPerson(with: "Some Person Name", to: databaseQueue)
		let person2Id = addContactPerson(with: "Other Person Name", to: databaseQueue)

		let location1Id = addLocation(with: "Some Location Name", to: databaseQueue)
		let location2Id = addLocation(with: "Other Location Name", to: databaseQueue)

		addContactPersonEncounter(date: "2021-02-12", contactPersonId: person1Id, to: databaseQueue)
		addContactPersonEncounter(date: "2021-02-11", contactPersonId: person2Id, to: databaseQueue)

		addLocationVisit(date: "2021-02-10", locationId: location1Id, to: databaseQueue)
		addLocationVisit(date: "2021-02-13", locationId: location2Id, to: databaseQueue)
	}

	private func checkV3Data(from databaseQueue: FMDatabaseQueue) {
		let contactPersonsResult = fetch(column: "ContactPerson", from: databaseQueue)
		XCTAssertEqual(contactPersonsResult.columnCount, 4)
		XCTAssertEqual(contactPersonsResult.columnName(for: 0), "id")
		XCTAssertEqual(contactPersonsResult.columnName(for: 1), "name")
		XCTAssertEqual(contactPersonsResult.columnName(for: 2), "phoneNumber")
		XCTAssertEqual(contactPersonsResult.columnName(for: 3), "emailAddress")

		var contactPersonCount = 0
		var contactPersonNames = [String]()
		while contactPersonsResult.next() {
			contactPersonCount += 1
			contactPersonNames.append(contactPersonsResult.string(forColumn: "name") ?? "")
		}
		XCTAssertEqual(contactPersonCount, 2)
		XCTAssertEqual(contactPersonNames, ["Some Person Name", "Other Person Name"])

		let locationsResult = fetch(column: "Location", from: databaseQueue)
		XCTAssertEqual(locationsResult.columnCount, 4)
		XCTAssertEqual(locationsResult.columnName(for: 0), "id")
		XCTAssertEqual(locationsResult.columnName(for: 1), "name")
		XCTAssertEqual(locationsResult.columnName(for: 2), "phoneNumber")
		XCTAssertEqual(locationsResult.columnName(for: 3), "emailAddress")

		var locationCount = 0
		var locationNames = [String]()
		while locationsResult.next() {
			locationCount += 1
			locationNames.append(locationsResult.string(forColumn: "name") ?? "")
		}
		XCTAssertEqual(locationCount, 2)
		XCTAssertEqual(locationNames, ["Some Location Name", "Other Location Name"])

		let contactPersonEncounterResult = fetch(column: "ContactPersonEncounter", from: databaseQueue)
		XCTAssertEqual(contactPersonEncounterResult.columnCount, 7)
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 0), "id")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 1), "date")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 2), "contactPersonId")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 3), "duration")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 4), "maskSituation")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 5), "setting")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 6), "circumstances")

		var contactPersonEncounter = 0
		var contactPersonEncounterDates = [String]()
		while contactPersonEncounterResult.next() {
			contactPersonEncounter += 1
			contactPersonEncounterDates.append(contactPersonEncounterResult.string(forColumn: "date") ?? "")
		}
		XCTAssertEqual(contactPersonEncounter, 2)
		XCTAssertEqual(contactPersonEncounterDates, ["2021-02-12", "2021-02-11"])

		let locationVisitResult = fetch(column: "LocationVisit", from: databaseQueue)
		XCTAssertEqual(locationVisitResult.columnCount, 5)
		XCTAssertEqual(locationVisitResult.columnName(for: 0), "id")
		XCTAssertEqual(locationVisitResult.columnName(for: 1), "date")
		XCTAssertEqual(locationVisitResult.columnName(for: 2), "locationId")
		XCTAssertEqual(locationVisitResult.columnName(for: 3), "durationInMinutes")
		XCTAssertEqual(locationVisitResult.columnName(for: 4), "circumstances")

		var locationVisitCount = 0
		var locationVisitDates = [String]()
		while locationVisitResult.next() {
			locationVisitCount += 1
			locationVisitDates.append(locationVisitResult.string(forColumn: "date") ?? "")
		}
		XCTAssertEqual(locationVisitCount, 2)
		XCTAssertEqual(locationVisitDates, ["2021-02-10", "2021-02-13"])
	}

	private func addContactPerson(with name: String, to databaseQueue: FMDatabaseQueue) -> Int {
		var lastInsertedRow: Int = -1

		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO ContactPerson (
					name
				)
				VALUES (
					SUBSTR(:name, 1, 250)
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
			lastInsertedRow = Int(database.lastInsertRowId)
		}
		return lastInsertedRow
	}

	private func addLocation(with name: String, to databaseQueue: FMDatabaseQueue) -> Int {
		var lastInsertedRow: Int = -1

		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO Location (
					name
				)
				VALUES (
					SUBSTR(:name, 1, 250)
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
			lastInsertedRow = Int(database.lastInsertRowId)
		}
		return lastInsertedRow
	}

	private func addContactPersonEncounter(
		date: String,
		contactPersonId: Int,
		to databaseQueue: FMDatabaseQueue
	) {
		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO ContactPersonEncounter (
					date,
					contactPersonId
				)
				VALUES (
					:date,
					:contactPersonId
				);
			"""
			let parameters: [String: Any] = [
				"date": date,
				"contactPersonId": contactPersonId
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	private func addLocationVisit(
		date: String,
		locationId: Int,
		to databaseQueue: FMDatabaseQueue
	) {
		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO LocationVisit (
					date,
					locationId
				)
				VALUES (
					:date,
					:locationId
				);
			"""
			let parameters: [String: Any] = [
				"date": date,
				"locationId": locationId
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	private func fetch(column: String, from databaseQueue: FMDatabaseQueue) -> FMResultSet {
		var _result: FMResultSet?
		databaseQueue.inDatabase { database in
			let sql = """
				SELECT * FROM \(column);
			"""

			_result = database.executeQuery(sql, withArgumentsIn: [])
		}

		guard let result = _result else {
			XCTFail("Could not fetch ContactPersons.")
			return FMResultSet()
		}

		return result
	}
}
