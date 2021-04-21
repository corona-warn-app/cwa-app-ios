////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryMigration3To4Tests: XCTestCase {

	func test_WHEN_migrationFrom3To4_THEN_NewColumsAreAdded_AND_OldDataIsNotDeleted() throws {

		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}

		// Create V3 schema.

		let schemaV3 = ContactDiaryStoreSchemaV3(databaseQueue: databaseQueue)

		let schemaV3Result = schemaV3.create()
		if case let .failure(error) = schemaV3Result {
			XCTFail("Error not expected: \(error)")
		}

		// Add data to V3 schema.

		addV3Data(to: databaseQueue)

		// Migrate to V4 schema.

		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: 4,
			migrations: [ContactDiaryMigration3To4(databaseQueue: databaseQueue)]
		)
		try migrator.migrate()

		// Check if the data is still valid after migration.

		checkV4Data(from: databaseQueue)

		// Check the user version.

		databaseQueue.inDatabase { database in
			XCTAssertEqual(database.userVersion, 4)
		}
	}

	private func addV3Data(to databaseQueue: FMDatabaseQueue) {
		let contactDiaryAccess = ContactDiaryAccess()

		let person1Id = contactDiaryAccess.addContactPerson(with: "Some Person Name", to: databaseQueue)
		let person2Id = contactDiaryAccess.addContactPerson(with: "Other Person Name", to: databaseQueue)

		let location1Id = contactDiaryAccess.addLocation(with: "Some Location Name", to: databaseQueue)
		let location2Id = contactDiaryAccess.addLocation(with: "Other Location Name", to: databaseQueue)

		contactDiaryAccess.addContactPersonEncounter(
			date: "2021-02-12",
			contactPersonId: person1Id,
			duration: .moreThan15Minutes,
			maskSituation: .withoutMask,
			setting: .inside,
			circumstances: "Some circumstances",
			to: databaseQueue
		)

		contactDiaryAccess.addContactPersonEncounter(
			date: "2021-02-11",
			contactPersonId: person2Id,
			duration: .moreThan15Minutes,
			maskSituation: .withoutMask,
			setting: .inside,
			circumstances: "Some circumstances",
			to: databaseQueue
		)

		contactDiaryAccess.addLocationVisit(
			date: "2021-02-10",
			locationId: location1Id,
			durationInMinutes: 42,
			circumstances: "Some circumstances",
			to: databaseQueue
		)
		contactDiaryAccess.addLocationVisit(
			date: "2021-02-13",
			locationId: location2Id,
			durationInMinutes: 42,
			circumstances: "Some circumstances",
			to: databaseQueue
		)
	}

	private func checkV4Data(from databaseQueue: FMDatabaseQueue) {
		let contactPersonsResult = databaseQueue.fetchAll(from: "ContactPerson")
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

		let locationsResult = databaseQueue.fetchAll(from: "Location")
		XCTAssertEqual(locationsResult.columnCount, 5)
		XCTAssertEqual(locationsResult.columnName(for: 0), "id")
		XCTAssertEqual(locationsResult.columnName(for: 1), "name")
		XCTAssertEqual(locationsResult.columnName(for: 2), "phoneNumber")
		XCTAssertEqual(locationsResult.columnName(for: 3), "emailAddress")
		XCTAssertEqual(locationsResult.columnName(for: 4), "traceLocationId")

		var locationCount = 0
		var locationNames = [String]()
		while locationsResult.next() {
			locationCount += 1
			locationNames.append(locationsResult.string(forColumn: "name") ?? "")
		}
		XCTAssertEqual(locationCount, 2)
		XCTAssertEqual(locationNames, ["Some Location Name", "Other Location Name"])

		let contactPersonEncounterResult = databaseQueue.fetchAll(from: "ContactPersonEncounter")
		XCTAssertEqual(contactPersonEncounterResult.columnCount, 7)
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 0), "id")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 1), "date")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 2), "duration")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 3), "maskSituation")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 4), "setting")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 5), "circumstances")
		XCTAssertEqual(contactPersonEncounterResult.columnName(for: 6), "contactPersonId")

		var contactPersonEncounter = 0
		var contactPersonEncounterDates = [String]()
		while contactPersonEncounterResult.next() {
			contactPersonEncounter += 1
			contactPersonEncounterDates.append(contactPersonEncounterResult.string(forColumn: "date") ?? "")
		}
		XCTAssertEqual(contactPersonEncounter, 2)
		XCTAssertEqual(contactPersonEncounterDates, ["2021-02-12", "2021-02-11"])

		let locationVisitResult = databaseQueue.fetchAll(from: "LocationVisit")
		XCTAssertEqual(locationVisitResult.columnCount, 6)
		XCTAssertEqual(locationVisitResult.columnName(for: 0), "id")
		XCTAssertEqual(locationVisitResult.columnName(for: 1), "date")
		XCTAssertEqual(locationVisitResult.columnName(for: 2), "durationInMinutes")
		XCTAssertEqual(locationVisitResult.columnName(for: 3), "circumstances")
		XCTAssertEqual(locationVisitResult.columnName(for: 4), "locationId")
		XCTAssertEqual(locationVisitResult.columnName(for: 5), "checkinId")

		var locationVisitCount = 0
		var locationVisitDates = [String]()
		while locationVisitResult.next() {
			locationVisitCount += 1
			locationVisitDates.append(locationVisitResult.string(forColumn: "date") ?? "")
		}
		XCTAssertEqual(locationVisitCount, 2)
		XCTAssertEqual(locationVisitDates, ["2021-02-10", "2021-02-13"])
	}
}
