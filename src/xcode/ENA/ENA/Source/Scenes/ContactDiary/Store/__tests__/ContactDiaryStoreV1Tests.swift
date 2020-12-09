////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryStoreV1Tests: XCTestCase {

	func test_When_addContactPerson_Then_ContactPersonIsPersisted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let result = store.addContactPerson(name: "Helge Schneider")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPerson = fetchEntries(for: "ContactPerson", with: id, from: database),
			  let name = contactPerson.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Helge Schneider")
	}

	func test_When_addLocation_Then_LocationIsPersisted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let result = store.addLocation(name: "Hinterm Mond")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let location = fetchEntries(for: "Location", with: id, from: database),
			  let name = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Hinterm Mond")
	}

	func test_When_addContactPersonEncounter_Then_ContactPersonEncounterIsPersisted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addPersonResult = store.addContactPerson(name: "Helge Schneider")

		guard case let .success(contactPersonId) = addPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let result = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "Some Date")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonEncounter = fetchEntries(for: "ContactPersonEncounter", with: id, from: database),
			  let date = contactPersonEncounter.string(forColumn: "date") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let fetchedContactPersonId = contactPersonEncounter.longLongInt(forColumn: "contactPersonId")

		XCTAssertEqual(date, "Some Date")
		XCTAssertEqual(fetchedContactPersonId, contactPersonId)
	}

	func test_When_addLocationVisit_Then_LocationVisitIsPersisted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addLocationResult = store.addLocation(name: "Nirgendwo")

		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let result = store.addLocationVisit(locationId: locationId, date: "Some Date")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let locationVisit = fetchEntries(for: "LocationVisit", with: id, from: database),
			  let date = locationVisit.string(forColumn: "date") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let fetchedLocationId = locationVisit.longLongInt(forColumn: "locationId")

		XCTAssertEqual(date, "Some Date")
		XCTAssertEqual(fetchedLocationId, locationId)
	}

	func test_When_updateContactPerson_Then_ContactPersonIsUpdated() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let result = store.addContactPerson(name: "Helge Schneider")

		guard case let .success(id) = result else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let updateResult = store.updateContactPerson(id: id, name: "Updated Name")

		guard case .success = updateResult else {
			XCTFail("Failed to update ContactPerson")
			return
		}

		guard let contactPerson = fetchEntries(for: "ContactPerson", with: id, from: database),
			  let name = contactPerson.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
	}

	func test_When_updateLocation_Then_LocationIsUpdated() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let result = store.addLocation(name: "Woanders")

		guard case let .success(id) = result else {
			XCTFail("Failed to add Location")
			return
		}

		let updateResult = store.updateLocation(id: id, name: "Updated Name")

		guard case .success = updateResult else {
			XCTFail("Failed to update Location")
			return
		}

		guard let location = fetchEntries(for: "Location", with: id, from: database),
			  let name = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
	}

	func test_When_removeContactPerson_Then_ContactPersonAndEncountersAreDeleted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addContactPersonResult = store.addContactPerson(name: "Helge Schneider")
		guard case let .success(contactPersonId) = addContactPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let addEncounterResult = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "Some Date")
		guard case let .success(encounterId) = addEncounterResult else {
			XCTFail("Failed to add ContactPersonEncounter")
			return
		}

		let removeResult = store.removeContactPerson(id: contactPersonId)
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchPersonResult = fetchEntries(for: "ContactPerson", with: contactPersonId, from: database)
		XCTAssertNil(fetchPersonResult)

		let fetchEncounterResult = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: database)
		XCTAssertNil(fetchEncounterResult)
	}

	func test_When_removeLocation_Then_LocationAndLocationVisitsAreDeleted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addLocationResult = store.addLocation(name: "Nicht hier")
		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let addLocationVisitResult = store.addLocationVisit(locationId: locationId, date: "Some Date")
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			XCTFail("Failed to add LocationVisit")
			return
		}

		let removeResult = store.removeLocation(id: locationId)
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchLocationResult = fetchEntries(for: "Location", with: locationId, from: database)
		XCTAssertNil(fetchLocationResult)

		let fetchLocationVisitResult = fetchEntries(for: "LocationVisit", with: locationVisitId, from: database)
		XCTAssertNil(fetchLocationVisitResult)
	}

	func test_When_removeContactPersonEncounter_Then_ContactPersonEncounterIsDeleted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addContactPersonResult = store.addContactPerson(name: "Helge Schneider")
		guard case let .success(contactPersonId) = addContactPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let addEncounterResult = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "Some Date")
		guard case let .success(encounterId) = addEncounterResult else {
			XCTFail("Failed to add ContactPersonEncounter")
			return
		}

		let encounterResultBeforeDelete = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: database)
		XCTAssertNotNil(encounterResultBeforeDelete)

		let removeEncounterResult = store.removeContactPersonEncounter(id: encounterId)
		if case let .failure(error) = removeEncounterResult {
			XCTFail("Error not expected: \(error)")
		}

		let encounterResultAfterDelete = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: database)
		XCTAssertNil(encounterResultAfterDelete)
	}

	func test_When_removeLocationVisit_Then_LocationVisitIsDeleted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addLocationResult = store.addLocation(name: "Nicht hier")
		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let addLocationVisitResult = store.addLocationVisit(locationId: locationId, date: "Some Date")
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			XCTFail("Failed to add LocationVisit")
			return
		}

		let fetchLocationVisitResult1 = fetchEntries(for: "LocationVisit", with: locationVisitId, from: database)
		XCTAssertNotNil(fetchLocationVisitResult1)

		let removeEncounterResult = store.removeLocationVisit(id: locationVisitId)
		if case let .failure(error) = removeEncounterResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchLocationVisitResult2 = fetchEntries(for: "LocationVisit", with: locationVisitId, from: database)
		XCTAssertNil(fetchLocationVisitResult2)
	}

	func test_When_removeAllLocations_Then_AllLocationsAreDeleted() {
		let database = FMDatabase.inMemory()
		let store = makeContactDiaryStore(with: database)

		let addLocation1Result = store.addLocation(name: "Nicht hier")
		guard case let .success(location1Id) = addLocation1Result else {
			XCTFail("Failed to add Location")
			return
		}

		let addLocation2Result = store.addLocation(name: "Woanders")
		guard case let .success(location2Id) = addLocation2Result else {
			XCTFail("Failed to add Location")
			return
		}

		let fetchLocation1ResultBeforeDelete = fetchEntries(for: "Location", with: location1Id, from: database)
		XCTAssertNotNil(fetchLocation1ResultBeforeDelete)
		let fetchLocation2ResultBeforeDelete = fetchEntries(for: "Location", with: location2Id, from: database)
		XCTAssertNotNil(fetchLocation2ResultBeforeDelete)

		let removeResult = store.removeAllLocations()
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchLocation1ResultAfterDelete = fetchEntries(for: "Location", with: location1Id, from: database)
		XCTAssertNil(fetchLocation1ResultAfterDelete)
		let fetchLocation2ResultAfterDelete = fetchEntries(for: "Location", with: location2Id, from: database)
		XCTAssertNil(fetchLocation2ResultAfterDelete)
	}

	private func fetchEntries(for table: String, with id: Int64, from database: FMDatabase) -> FMResultSet? {
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

		guard let result = database.executeQuery(sql, withParameterDictionary: nil) else {
			return nil
		}

		guard result.next() else {
			return nil
		}

		return result
	}

	private func makeContactDiaryStore(with database: FMDatabase) -> ContactDiaryStoreV1 {
		let queue = DispatchQueue(label: "ContactDiaryStoreSchemaV1TestsQueue")
		let schema = ContactDiaryStoreSchemaV1(database: database, queue: queue)

		return ContactDiaryStoreV1(
			database: database,
			queue: queue,
			schema: schema
		)
	}
}
