////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
import OpenCombine
@testable import ENA

// swiftlint:disable:next type_body_length
class ContactDiaryStoreTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	func test_When_addContactPerson_Then_ContactPersonIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addContactPerson(name: "Helge Schneider")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonResult = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
			  let name = contactPersonResult.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Helge Schneider")
	}

	func test_When_addLocation_Then_LocationIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addLocation(name: "Hinterm Mond")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Hinterm Mond")
	}
	
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
	
	func test_When_addContactPersonEncounter_Then_ContactPersonEncounterIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addPersonResult = store.addContactPerson(name: "Helge Schneider")

		guard case let .success(contactPersonId) = addPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let result = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "2020-12-10")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonEncounter = fetchEntries(for: "ContactPersonEncounter", with: id, from: databaseQueue),
			  let date = contactPersonEncounter.string(forColumn: "date") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let fetchedContactPersonId = Int(contactPersonEncounter.int(forColumn: "contactPersonId"))

		XCTAssertEqual(date, "2020-12-10")
		XCTAssertEqual(fetchedContactPersonId, contactPersonId)
	}

	func test_When_addLocationVisit_Then_LocationVisitIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nirgendwo")

		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let result = store.addLocationVisit(locationId: locationId, date: "2020-12-10")

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let locationVisit = fetchEntries(for: "LocationVisit", with: id, from: databaseQueue),
			  let date = locationVisit.string(forColumn: "date") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let fetchedLocationId = Int(locationVisit.int(forColumn: "locationId"))

		XCTAssertEqual(date, "2020-12-10")
		XCTAssertEqual(fetchedLocationId, locationId)
	}

	func test_When_updateContactPerson_Then_ContactPersonIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

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

		guard let contactPerson = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
			  let name = contactPerson.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
	}

	func test_When_updateLocation_Then_LocationIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

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

		guard let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
	}

	func test_When_removeContactPerson_Then_ContactPersonAndEncountersAreDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addContactPersonResult = store.addContactPerson(name: "Helge Schneider")
		guard case let .success(contactPersonId) = addContactPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let addEncounterResult = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "2020-12-10")
		guard case let .success(encounterId) = addEncounterResult else {
			XCTFail("Failed to add ContactPersonEncounter")
			return
		}

		let removeResult = store.removeContactPerson(id: contactPersonId)
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchPersonResult = fetchEntries(for: "ContactPerson", with: contactPersonId, from: databaseQueue)
		XCTAssertNil(fetchPersonResult)

		let fetchEncounterResult = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: databaseQueue)
		XCTAssertNil(fetchEncounterResult)
	}

	func test_When_removeLocation_Then_LocationAndLocationVisitsAreDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nicht hier")
		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let addLocationVisitResult = store.addLocationVisit(locationId: locationId, date: "2020-12-10")
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			XCTFail("Failed to add LocationVisit")
			return
		}

		let removeResult = store.removeLocation(id: locationId)
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchLocationResult = fetchEntries(for: "Location", with: locationId, from: databaseQueue)
		XCTAssertNil(fetchLocationResult)

		let fetchLocationVisitResult = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue)
		XCTAssertNil(fetchLocationVisitResult)
	}

	func test_When_removeContactPersonEncounter_Then_ContactPersonEncounterIsDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addContactPersonResult = store.addContactPerson(name: "Helge Schneider")
		guard case let .success(contactPersonId) = addContactPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let addEncounterResult = store.addContactPersonEncounter(contactPersonId: contactPersonId, date: "2020-12-10")
		guard case let .success(encounterId) = addEncounterResult else {
			XCTFail("Failed to add ContactPersonEncounter")
			return
		}

		let encounterResultBeforeDelete = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: databaseQueue)
		XCTAssertNotNil(encounterResultBeforeDelete)

		let removeEncounterResult = store.removeContactPersonEncounter(id: encounterId)
		if case let .failure(error) = removeEncounterResult {
			XCTFail("Error not expected: \(error)")
		}

		let encounterResultAfterDelete = fetchEntries(for: "ContactPersonEncounter", with: encounterId, from: databaseQueue)
		XCTAssertNil(encounterResultAfterDelete)
	}

	func test_When_removeLocationVisit_Then_LocationVisitIsDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nicht hier")
		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let addLocationVisitResult = store.addLocationVisit(locationId: locationId, date: "2020-12-10")
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			XCTFail("Failed to add LocationVisit")
			return
		}

		let fetchLocationVisitResult1 = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue)
		XCTAssertNotNil(fetchLocationVisitResult1)

		let removeEncounterResult = store.removeLocationVisit(id: locationVisitId)
		if case let .failure(error) = removeEncounterResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchLocationVisitResult2 = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue)
		XCTAssertNil(fetchLocationVisitResult2)
	}

	func test_When_removeAllContactPersons_Then_AllContactPersonsAreDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addContactPerson1Result = store.addContactPerson(name: "Some Person")
		guard case let .success(contactPerson1Id) = addContactPerson1Result else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let addContactPerson2Result = store.addContactPerson(name: "Other Person")
		guard case let .success(contactPerson2Id) = addContactPerson2Result else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let fetchPerson1ResultBeforeDelete = fetchEntries(for: "ContactPerson", with: contactPerson1Id, from: databaseQueue)
		XCTAssertNotNil(fetchPerson1ResultBeforeDelete)
		let fetchPerson2ResultBeforeDelete = fetchEntries(for: "ContactPerson", with: contactPerson2Id, from: databaseQueue)
		XCTAssertNotNil(fetchPerson2ResultBeforeDelete)

		let removeResult = store.removeAllContactPersons()
		if case let .failure(error) = removeResult {
			XCTFail("Error not expected: \(error)")
		}

		let fetchPerson1ResultAfterDelete = fetchEntries(for: "ContactPerson", with: contactPerson1Id, from: databaseQueue)
		XCTAssertNil(fetchPerson1ResultAfterDelete)
		let fetchPerson2ResultAfterDelete = fetchEntries(for: "ContactPerson", with: contactPerson2Id, from: databaseQueue)
		XCTAssertNil(fetchPerson2ResultAfterDelete)
	}

	func test_When_sinkOnDiaryDays_Then_diaryDaysAreReturnedWithCorrectStartingDay() throws {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

		// Set time between midnight and 1 am local time to check that the correct starting day considering the current time zone is returned.
		let dateString = "2020-12-31 00:10"
		let today = try XCTUnwrap(dateFormatter.date(from: dateString))

		let databaseQueue = makeDatabaseQueue()
		let dateProviderStub = DateProviderStub(today: today)
		let store = makeContactDiaryStore(with: databaseQueue, dateProvider: dateProviderStub)

		store.diaryDaysPublisher.sink { diaryDays in
			// Only the last 15 days (including today) should be returned.
			XCTAssertEqual(diaryDays.count, 15)

			XCTAssertEqual(diaryDays[0].formattedDate, "Donnerstag, 31.12.20")
		}.store(in: &subscriptions)
	}

	func test_When_sinkOnDiaryDays_Then_diaryDaysWithCorrectEntriesAreReturned() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let today = Date()

		guard let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: today),
			  let thirteenDaysAgo = Calendar.current.date(byAdding: .day, value: -13, to: today),
			  let seventeenDaysAgo = Calendar.current.date(byAdding: .day, value: -17, to: today) else {
			fatalError("Could not create test dates.")
		}

		let emmaHicksPersonId = addContactPerson(name: "Emma Hicks", to: store)
		let maryBarryPersonId = addContactPerson(name: "Mary Barry", to: store)

		let conistonLocationId = addLocation(name: "Coniston", to: store)
		let kincardineLocationId = addLocation(name: "Kincardine", to: store)

		// Today
		addLocationVisit(locationId: conistonLocationId, date: today, store: store)
		addLocationVisit(locationId: kincardineLocationId, date: today, store: store)
		addPersonEncounter(personId: emmaHicksPersonId, date: today, store: store)

		// 10 days ago
		addLocationVisit(locationId: kincardineLocationId, date: tenDaysAgo, store: store)
		addPersonEncounter(personId: maryBarryPersonId, date: tenDaysAgo, store: store)

		// 16 days ago (should not be persisted)
		addPersonEncounter(personId: maryBarryPersonId, date: thirteenDaysAgo, store: store)
		addPersonEncounter(personId: emmaHicksPersonId, date: thirteenDaysAgo, store: store)

		// 17 days ago (should not be persisted)
		addLocationVisit(locationId: kincardineLocationId, date: seventeenDaysAgo, store: store)
		addLocationVisit(locationId: conistonLocationId, date: seventeenDaysAgo, store: store)

		store.diaryDaysPublisher.sink { diaryDays in
			// Only the last 14 days (including today) should be returned.
			XCTAssertEqual(diaryDays.count, 15)

			for diaryDay in diaryDays {
				XCTAssertEqual(diaryDay.entries.count, 4)
			}

			// Test the data for today
			let todayDiaryDay = diaryDays[0]

			self.checkPersonEntry(entry: todayDiaryDay.entries[0], name: "Emma Hicks", id: emmaHicksPersonId, isSelected: true)
			self.checkPersonEntry(entry: todayDiaryDay.entries[1], name: "Mary Barry", id: maryBarryPersonId, isSelected: false)

			self.checkLocationEntry(entry: todayDiaryDay.entries[2], name: "Coniston", id: conistonLocationId, isSelected: true)
			self.checkLocationEntry(entry: todayDiaryDay.entries[3], name: "Kincardine", id: kincardineLocationId, isSelected: true)

			// Test the data for ten days ago
			let tenDaysAgoDiaryDay = diaryDays[10]

			self.checkPersonEntry(entry: tenDaysAgoDiaryDay.entries[0], name: "Emma Hicks", id: emmaHicksPersonId, isSelected: false)
			self.checkPersonEntry(entry: tenDaysAgoDiaryDay.entries[1], name: "Mary Barry", id: maryBarryPersonId, isSelected: true)

			self.checkLocationEntry(entry: tenDaysAgoDiaryDay.entries[2], name: "Coniston", id: conistonLocationId, isSelected: false)
			self.checkLocationEntry(entry: tenDaysAgoDiaryDay.entries[3], name: "Kincardine", id: kincardineLocationId, isSelected: true)

			// Test the data for thirteen days ago
			let sixteenDaysAgoDiaryDay = diaryDays[13]
			self.checkPersonEntry(entry: sixteenDaysAgoDiaryDay.entries[0], name: "Emma Hicks", id: emmaHicksPersonId, isSelected: true)
			self.checkPersonEntry(entry: sixteenDaysAgoDiaryDay.entries[1], name: "Mary Barry", id: maryBarryPersonId, isSelected: true)

			self.checkLocationEntry(entry: sixteenDaysAgoDiaryDay.entries[2], name: "Coniston", id: conistonLocationId, isSelected: false)
			self.checkLocationEntry(entry: sixteenDaysAgoDiaryDay.entries[3], name: "Kincardine", id: kincardineLocationId, isSelected: false)

		}.store(in: &subscriptions)
	}

	func test_When_cleanupIsCalled_Then_EntriesOlderThen16DaysAreDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let today = Date()

		guard let seventeenDaysAgo = Calendar.current.date(byAdding: .day, value: -17, to: today) else {
			fatalError("Could not create test dates.")
		}

		let emmaHicksPersonId = addContactPerson(name: "Emma Hicks", to: store)
		let kincardineLocationId = addLocation(name: "Kincardine", to: store)

		let personEncounterId = addPersonEncounter(personId: emmaHicksPersonId, date: seventeenDaysAgo, store: store)
		let locationVisitId = addLocationVisit(locationId: kincardineLocationId, date: seventeenDaysAgo, store: store)

		let personEncouterBeforeCleanupResult = fetchEntries(for: "ContactPersonEncounter", with: personEncounterId, from: databaseQueue)
		XCTAssertNotNil(personEncouterBeforeCleanupResult)

		let locationVisitBeforeCleanupResult = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue)
		XCTAssertNotNil(locationVisitBeforeCleanupResult)

		let cleanupResult = store.cleanup()
		guard case .success = cleanupResult else {
			fatalError("Failed to cleanup store.")
		}

		let personEncouterResult = fetchEntries(for: "ContactPersonEncounter", with: personEncounterId, from: databaseQueue)
		XCTAssertNil(personEncouterResult)

		let locationVisitResult = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue)
		XCTAssertNil(locationVisitResult)
	}

	func test_OrderIsCorrect() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		addContactPerson(name: "Adam Sandale", to: store)
		addContactPerson(name: "Adam Sandale", to: store)
		addContactPerson(name: "emma Hicks", to: store)

		addLocation(name: "Amsterdam", to: store)
		addLocation(name: "Berlin", to: store)
		addLocation(name: "berlin", to: store)

		store.diaryDaysPublisher.sink { diaryDays in
			let storedNames: [String] =
				diaryDays[0].entries.map { entry in
					switch entry {
					case .contactPerson(let person):
						return person.name
					case .location(let location):
						return location.name
					}
				}

			let expectedNames = [
				"Adam Sandale",
				"Adam Sandale",
				"emma Hicks",
				"Amsterdam",
				"Berlin",
				"berlin"
			]

			XCTAssertEqual(storedNames, expectedNames)

			let storedIds: [Int] =
				diaryDays[0].entries.map { entry in
					switch entry {
					case .contactPerson(let person):
						return person.id
					case .location(let location):
						return location.id
					}
				}

			let expectedIds = [
				Int(1),
				Int(2),
				Int(3),
				Int(1),
				Int(2),
				Int(3)
			]

			XCTAssertEqual(storedIds, expectedIds)
		}.store(in: &subscriptions)
	}

	func test_When_ContactPersonNameIsToLong_Then_ContactPersonNameIsTruncated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let stringWith251Chars = String(repeating: "Y", count: 251)

		let addPersonResult = store.addContactPerson(name: stringWith251Chars)
		guard case .success(let personId) = addPersonResult,
			  let contactPerson = fetchEntries(for: "ContactPerson", with: personId, from: databaseQueue),
			  let name = contactPerson.string(forColumn: "name")else {
			fatalError("An error is not expected.")
		}

		let expectedName = String(repeating: "Y", count: 250)

		XCTAssertEqual(name, expectedName)

		let updateResult = store.updateContactPerson(id: personId, name: stringWith251Chars)

		guard case .success = updateResult,
			  let contactPersonUpdated = fetchEntries(for: "ContactPerson", with: personId, from: databaseQueue),
			  let nameUpdated = contactPersonUpdated.string(forColumn: "name")  else {
			fatalError("An error is not expected.")
		}

		XCTAssertEqual(nameUpdated, expectedName)
	}

	func test_When_LocationNameIsToLong_Then_LocationNameIsTruncated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let stringWith251Chars = String(repeating: "Y", count: 251)

		let addLocationResult = store.addLocation(name: stringWith251Chars)
		guard case .success(let locationId) = addLocationResult,
			  let location = fetchEntries(for: "Location", with: locationId, from: databaseQueue),
			  let name = location.string(forColumn: "name")else {
			fatalError("An error is not expected.")
		}

		let expectedName = String(repeating: "Y", count: 250)

		XCTAssertEqual(name, expectedName)

		let updateResult = store.updateLocation(id: locationId, name: stringWith251Chars)

		guard case .success = updateResult,
			  let locationUpdated = fetchEntries(for: "Location", with: locationId, from: databaseQueue),
			  let nameUpdated = locationUpdated.string(forColumn: "name")  else {
			fatalError("An error is not expected.")
		}

		XCTAssertEqual(nameUpdated, expectedName)
	}

	func test_When_export_Then_CorrectStringIsReturned() {
		guard let today = dateFormatter.date(from: "2020-12-15") else {
			fatalError("Failed to create date.")
		}

		guard let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: today),
			  let thirteenDaysAgo = Calendar.current.date(byAdding: .day, value: -13, to: today) else {
			fatalError("Could not create test dates.")
		}

		let dateProviderStub = DateProviderStub(today: today)

		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue, dateProvider: dateProviderStub)

		let adamSandaleId = addContactPerson(name: "Adam Sandale", to: store)
		let emmaHicksId = addContactPerson(name: "Emma Hicks", to: store)

		let amsterdamLocationId = addLocation(name: "Amsterdam", to: store)
		let berlinId = addLocation(name: "Berlin", to: store)

		addLocationVisit(locationId: amsterdamLocationId, date: today, store: store)
		addLocationVisit(locationId: berlinId, date: today, store: store)
		addPersonEncounter(personId: emmaHicksId, date: today, store: store)
		addPersonEncounter(personId: adamSandaleId, date: today, store: store)

		addLocationVisit(locationId: amsterdamLocationId, date: tenDaysAgo, store: store)
		addPersonEncounter(personId: emmaHicksId, date: tenDaysAgo, store: store)

		addLocationVisit(locationId: amsterdamLocationId, date: thirteenDaysAgo, store: store)
		addLocationVisit(locationId: berlinId, date: thirteenDaysAgo, store: store)
		addPersonEncounter(personId: emmaHicksId, date: thirteenDaysAgo, store: store)
		addPersonEncounter(personId: adamSandaleId, date: thirteenDaysAgo, store: store)

		let exportResult = store.export()
		guard case let .success(exportString) = exportResult else {
			XCTFail("Error not expected")
			return
		}

		let expectedString = """
			Kontakte der letzten 15 Tage (01.12.2020 - 15.12.2020)
			Die nachfolgende Liste dient dem zuständigen Gesundheitsamt zur Kontaktnachverfolgung gem. § 25 IfSG.

			15.12.2020 Adam Sandale
			15.12.2020 Emma Hicks
			15.12.2020 Amsterdam
			15.12.2020 Berlin
			05.12.2020 Emma Hicks
			05.12.2020 Amsterdam
			02.12.2020 Adam Sandale
			02.12.2020 Emma Hicks
			02.12.2020 Amsterdam
			02.12.2020 Berlin

			"""

		XCTAssertEqual(exportString, expectedString)
	}

	func test_When_Reset_Then_DatabaseIsEmpty() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		// Add data and check if its persisted.

		let personId = addContactPerson(name: "Some Person", to: store)
		addPersonEncounter(personId: personId, date: Date(), store: store)
		let locationId = addLocation(name: "Some Location", to: store)
		addLocationVisit(locationId: locationId, date: Date(), store: store)

		XCTAssertNotNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPerson", with: personId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPersonEncounter", with: personId, from: databaseQueue))

		// Reset store and check if date was removed.

		guard case .success = store.reset() else {
			XCTFail("Failure not expected.")
			return
		}

		let numberOfDiaryEntries = store.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfDiaryEntries, 0)

		XCTAssertNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "ContactPerson", with: personId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "ContactPersonEncounter", with: personId, from: databaseQueue))

		// Add again some data an check if persistence is working again.

		let person1Id = addContactPerson(name: "Some Person", to: store)
		addPersonEncounter(personId: person1Id, date: Date(), store: store)
		let location1Id = addLocation(name: "Some Location", to: store)
		addLocationVisit(locationId: location1Id, date: Date(), store: store)

		XCTAssertNotNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPerson", with: personId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPersonEncounter", with: personId, from: databaseQueue))
	}

	func test_when_storeIsCorrupted_then_makeDeletesAndRecreatesStore() {
		let store = ContactDiaryStore.make()
		_ = store.addContactPerson(name: "Some Name")
		let numberOfEntries = store.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfEntries, 15)
		store.close()

		let fileManager = FileManager.default
		guard let storeURL = try? fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("ContactDiary")
				.appendingPathComponent("ContactDiary")
				.appendingPathExtension("sqlite") else {
			fatalError("Could not create folder.")
		}

		do {
			let corruptingString = "I will corrupt the database"
			try corruptingString.write(to: storeURL, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			XCTFail("Error is not expected: \(error)")
		}

		let storeAfterRescue = ContactDiaryStore.make()
		_ = storeAfterRescue.addContactPerson(name: "Some Name")
		let numberOfEntriesAfterRescue = storeAfterRescue.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfEntriesAfterRescue, 15)
	}

//	func test_when_newDatabaseVersionExist_then_migrationIsExcuted() {
//		let databaseQueue = makeDatabaseQueue()
//		let store = makeContactDiaryV1Store(with: databaseQueue)
//
//		let oldName = "007"
//		let oldLocation = "00005"
//		let expectedFetchedOldName = "7"
//		let expectedFetchedOldLocation = "5"
//
//		let nameResult = store.addContactPerson(name: oldName)
//		let locationResult = store.addLocation(name: oldLocation)
//
//		if case let .failure(error) = nameResult {
//			XCTFail("Error not expected: \(error)")
//		}
//
//		// initializing newest version store will trigger the migration then we check the database if the name is migrated
//		 let newStore = makeContactDiaryV2Store(with: databaseQueue)
//
//		guard case let .success(id) = nameResult,
//			  let contactPersonResult = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
//			  let name = contactPersonResult.string(forColumn: "name") else {
//			XCTFail("Failed to fetch ContactPerson")
//			return
//		}
//		guard case let .success(locationID) = locationResult,
//			  let location = fetchEntries(for: "Location", with: locationID, from: databaseQueue),
//			  let locationName = location.string(forColumn: "name") else {
//			XCTFail("Failed to fetch ContactPerson")
//			return
//		}
//
//		// result saved in V1 without prefix zeros
//		XCTAssertEqual(name, expectedFetchedOldName)
//		XCTAssertEqual(locationName, expectedFetchedOldLocation)
//
//
//		// now that the new store has the old data, lets test if prefix zeros are saved correctly
//
//		let expectedFetchedNewName = "00008"
//		let expectedFetchedNewLocation = "00000"
//
//		let newNameResult = newStore.addContactPerson(name: expectedFetchedNewName)
//		let newLocationResult = newStore.addLocation(name: expectedFetchedNewLocation)
//
//		guard case let .success(newNameId) = newNameResult,
//			  let newContactPersonResult = fetchEntries(for: "ContactPerson", with: newNameId, from: databaseQueue),
//			  let newName = newContactPersonResult.string(forColumn: "name") else {
//			XCTFail("Failed to fetch ContactPerson")
//			return
//		}
//		guard case let .success(newLocationID) = newLocationResult,
//			  let newLocation = fetchEntries(for: "Location", with: newLocationID, from: databaseQueue),
//			  let newLocationName = newLocation.string(forColumn: "name") else {
//			XCTFail("Failed to fetch ContactPerson")
//			return
//		}
//
//		// result saved in V2 with prefix zeros
//		XCTAssertEqual(expectedFetchedNewName, newName)
//		XCTAssertEqual(expectedFetchedNewLocation, newLocationName)
//
//	}
	
	private func checkLocationEntry(entry: DiaryEntry, name: String, id: Int, isSelected: Bool) {
		guard case .location(let location) = entry else {
			fatalError("Not expected")
		}
		XCTAssertEqual(location.name, name)
		XCTAssertEqual(location.id, id)
		XCTAssertEqual(entry.isSelected, isSelected)
	}

	private func checkPersonEntry(entry: DiaryEntry, name: String, id: Int, isSelected: Bool) {
		guard case .contactPerson(let person) = entry else {
			fatalError("Not expected")
		}
		XCTAssertEqual(person.name, name)
		XCTAssertEqual(person.id, id)
		XCTAssertEqual(entry.isSelected, isSelected)
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

	@discardableResult
	private func addContactPerson(name: String, to store: ContactDiaryStore) -> Int {
		let addContactPersonResult = store.addContactPerson(name: name)
		guard case let .success(contactPersonId) = addContactPersonResult else {
			fatalError("Failed to add ContactPerson")
		}
		return contactPersonId
	}

	@discardableResult
	private func addLocation(name: String, to store: ContactDiaryStore) -> Int {
		let addLocationResult = store.addLocation(name: name)
		guard case let .success(locationId) = addLocationResult else {
			fatalError("Failed to add Location")
		}
		return locationId
	}

	@discardableResult
	private func addLocationVisit(locationId: Int, date: Date, store: ContactDiaryStore) -> Int {
		let dateString = dateFormatter.string(from: date)
		let addLocationVisitResult = store.addLocationVisit(locationId: locationId, date: dateString)
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			fatalError("Failed to add LocationVisit")
		}
		return locationVisitId
	}

	@discardableResult
	private func addPersonEncounter(personId: Int, date: Date, store: ContactDiaryStore) -> Int {
		let dateString = dateFormatter.string(from: date)
		let addEncounterResult = store.addContactPersonEncounter(contactPersonId: personId, date: dateString)
		guard case let .success(encounterId) = addEncounterResult else {
			fatalError("Failed to add ContactPersonEncounter")
		}
		return encounterId
	}

	private func makeDatabaseQueue() -> FMDatabaseQueue {
		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			fatalError("Could not create FMDatabaseQueue.")
		}
		return databaseQueue
	}

	private func makeContactDiaryStore(with databaseQueue: FMDatabaseQueue, dateProvider: DateProviding = DateProvider()) -> ContactDiaryStore {
		let schema = ContactDiaryStoreSchemaV3(databaseQueue: databaseQueue)
		let migrations: [Migration] = [ContactDiaryMigration1To2(databaseQueue: databaseQueue), ContactDiaryMigration2To3(databaseQueue: databaseQueue)]
		let migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 3, migrations: migrations)

		guard let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: schema,
			key: "Dummy",
			dateProvider: dateProvider,
			migrator: migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}

	private func makeContactDiaryV1Store(with databaseQueue: FMDatabaseQueue, dateProvider: DateProviding = DateProvider()) -> ContactDiaryStore {
		let schema = ContactDiaryStoreSchemaV1(databaseQueue: databaseQueue)
		let migrations: [Migration] = [ContactDiaryMigration1To2(databaseQueue: databaseQueue)]
		let migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 1, migrations: migrations)

		guard let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: schema,
			key: "Dummy",
			dateProvider: dateProvider,
			migrator: migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}

	private func makeContactDiaryV2Store(with databaseQueue: FMDatabaseQueue, dateProvider: DateProviding = DateProvider()) -> ContactDiaryStore {
		let schema = ContactDiaryStoreSchemaV2(databaseQueue: databaseQueue)
		let migrations: [Migration] = [ContactDiaryMigration1To2(databaseQueue: databaseQueue)]
		let migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 2, migrations: migrations)

		guard let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: schema,
			key: "Dummy",
			dateProvider: dateProvider,
			migrator: migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}

	private func makeContactDiaryV3Store(with databaseQueue: FMDatabaseQueue, dateProvider: DateProviding = DateProvider()) -> ContactDiaryStore {
		let schema = ContactDiaryStoreSchemaV3(databaseQueue: databaseQueue)
		let migrations: [Migration] = [ContactDiaryMigration2To3(databaseQueue: databaseQueue)]
		let migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 3, migrations: migrations)

		guard let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: schema,
			key: "Dummy",
			dateProvider: dateProvider,
			migrator: migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

}

struct DateProviderStub: DateProviding {
	var today: Date

	// swiftlint:disable:next file_length
}
