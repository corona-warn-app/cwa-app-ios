////
// 🦠 Corona-Warn-App
//

// CJE: Include in ENATests target

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

		let result = store.addContactPerson(
			name: "Helge Schneider",
			phoneNumber: "123456",
			emailAddress: "some@mail.de"
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonResult = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
			  let name = contactPersonResult.string(forColumn: "name"),
			  let phoneNumber = contactPersonResult.string(forColumn: "phoneNumber"),
			  let emailAddress = contactPersonResult.string(forColumn: "emailAddress") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Helge Schneider")
		XCTAssertEqual(phoneNumber, "123456")
		XCTAssertEqual(emailAddress, "some@mail.de")
	}

	func test_When_addLocation_Then_LocationIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addLocation(
			name: "Hinterm Mond",
			phoneNumber: "123456",
			emailAddress: "some@mail.de",
			traceLocationGUID: "Some Id"
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name"),
			  let phoneNumber = location.string(forColumn: "phoneNumber"),
			  let emailAddress = location.string(forColumn: "emailAddress"),
			  let traceLocationGUID = location.string(forColumn: "traceLocationGUID") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Hinterm Mond")
		XCTAssertEqual(phoneNumber, "123456")
		XCTAssertEqual(emailAddress, "some@mail.de")
		XCTAssertEqual(traceLocationGUID, "Some Id")
	}

	func test_When_addLocationWithNilValues_Then_LocationIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addLocation(
			name: "Hinterm Mond",
			phoneNumber: "123456",
			emailAddress: "some@mail.de",
			traceLocationGUID: nil
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name"),
			  let phoneNumber = location.string(forColumn: "phoneNumber"),
			  let emailAddress = location.string(forColumn: "emailAddress") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Hinterm Mond")
		XCTAssertEqual(phoneNumber, "123456")
		XCTAssertEqual(emailAddress, "some@mail.de")
		XCTAssertNil(location.string(forColumn: "traceLocationGUID"))
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

		let result = store.addContactPersonEncounter(
			contactPersonId: contactPersonId,
			date: "2020-12-10",
			duration: .lessThan15Minutes,
			maskSituation: .withMask,
			setting: .outside,
			circumstances: "Some circumstances."
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let contactPersonEncounter = fetchEntries(for: "ContactPersonEncounter", with: id, from: databaseQueue),
			  let date = contactPersonEncounter.string(forColumn: "date"),
			  let circumstances = contactPersonEncounter.string(forColumn: "circumstances")
			  else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let duration = Int(contactPersonEncounter.int(forColumn: "duration"))
		let maskSituation = Int(contactPersonEncounter.int(forColumn: "maskSituation"))
		let setting = Int(contactPersonEncounter.int(forColumn: "setting"))

		let fetchedContactPersonId = Int(contactPersonEncounter.int(forColumn: "contactPersonId"))

		XCTAssertEqual(date, "2020-12-10")
		XCTAssertEqual(fetchedContactPersonId, contactPersonId)
		XCTAssertEqual(circumstances, "Some circumstances.")
		XCTAssertEqual(duration, ContactPersonEncounter.Duration.lessThan15Minutes.rawValue)
		XCTAssertEqual(maskSituation, ContactPersonEncounter.MaskSituation.withMask.rawValue)
		XCTAssertEqual(setting, ContactPersonEncounter.Setting.outside.rawValue)
	}

	func test_When_updateContactPersonEncounter_Then_ContactPersonEncounterIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addPersonResult = store.addContactPerson(name: "Helge Schneider")

		guard case let .success(contactPersonId) = addPersonResult else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let result = store.addContactPersonEncounter(
			contactPersonId: contactPersonId,
			date: "2020-12-10",
			duration: .lessThan15Minutes,
			maskSituation: .withMask,
			setting: .outside,
			circumstances: "Some circumstances."
		)

		guard case let .success(personEncounterId) = result else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		store.updateContactPersonEncounter(
			id: personEncounterId,
			date: "2020-12-11",
			duration: .moreThan15Minutes,
			maskSituation: .withoutMask,
			setting: .inside,
			circumstances: "Some other circumstances."
		)

		guard let contactPersonEncounter = fetchEntries(for: "ContactPersonEncounter", with: personEncounterId, from: databaseQueue),
			  let date = contactPersonEncounter.string(forColumn: "date"),
			  let circumstances = contactPersonEncounter.string(forColumn: "circumstances")
			  else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let duration = Int(contactPersonEncounter.int(forColumn: "duration"))
		let maskSituation = Int(contactPersonEncounter.int(forColumn: "maskSituation"))
		let setting = Int(contactPersonEncounter.int(forColumn: "setting"))

		let fetchedContactPersonId = Int(contactPersonEncounter.int(forColumn: "contactPersonId"))

		XCTAssertEqual(date, "2020-12-11")
		XCTAssertEqual(fetchedContactPersonId, contactPersonId)
		XCTAssertEqual(circumstances, "Some other circumstances.")
		XCTAssertEqual(duration, ContactPersonEncounter.Duration.moreThan15Minutes.rawValue)
		XCTAssertEqual(maskSituation, ContactPersonEncounter.MaskSituation.withoutMask.rawValue)
		XCTAssertEqual(setting, ContactPersonEncounter.Setting.inside.rawValue)
	}

	func test_When_addLocationVisit_Then_LocationVisitIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nirgendwo")

		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let result = store.addLocationVisit(
			locationId: locationId,
			date: "2020-12-10",
			durationInMinutes: 42,
			circumstances: "Some circumstances.",
			checkinId: 42
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let locationVisit = fetchEntries(for: "LocationVisit", with: id, from: databaseQueue),
			  let date = locationVisit.string(forColumn: "date"),
			  let circumstances = locationVisit.string(forColumn: "circumstances")
		else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let durationInMinutes = Int(locationVisit.int(forColumn: "durationInMinutes"))
		let fetchedLocationId = Int(locationVisit.int(forColumn: "locationId"))
		let checkinId = Int(locationVisit.int(forColumn: "checkinId"))

		XCTAssertEqual(date, "2020-12-10")
		XCTAssertEqual(fetchedLocationId, locationId)
		XCTAssertEqual(circumstances, "Some circumstances.")
		XCTAssertEqual(durationInMinutes, 42)
		XCTAssertEqual(checkinId, 42)
	}

	func test_When_addLocationVisitWithNilValues_Then_LocationVisitIsPersisted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nirgendwo")

		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let result = store.addLocationVisit(
			locationId: locationId,
			date: "2020-12-10",
			durationInMinutes: 42,
			circumstances: "Some circumstances.",
			checkinId: nil
		)

		if case let .failure(error) = result {
			XCTFail("Error not expected: \(error)")
		}

		guard case let .success(id) = result,
			  let locationVisit = fetchEntries(for: "LocationVisit", with: id, from: databaseQueue),
			  let date = locationVisit.string(forColumn: "date"),
			  let circumstances = locationVisit.string(forColumn: "circumstances")
		else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let durationInMinutes = Int(locationVisit.int(forColumn: "durationInMinutes"))

		let fetchedLocationId = Int(locationVisit.int(forColumn: "locationId"))

		XCTAssertEqual(date, "2020-12-10")
		XCTAssertEqual(fetchedLocationId, locationId)
		XCTAssertEqual(circumstances, "Some circumstances.")
		XCTAssertEqual(durationInMinutes, 42)
		XCTAssertNil(locationVisit.string(forColumn: "checkinId"))
	}

	func test_When_updateLocationVisit_Then_LocationVisitIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let addLocationResult = store.addLocation(name: "Nirgendwo")

		guard case let .success(locationId) = addLocationResult else {
			XCTFail("Failed to add Location")
			return
		}

		let result = store.addLocationVisit(
			locationId: locationId,
			date: "2020-12-10",
			durationInMinutes: 42,
			circumstances: "Some circumstances.",
			checkinId: nil
		)

		guard case let .success(locationVisitId) = result else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		store.updateLocationVisit(
			id: locationVisitId,
			date: "2020-12-11",
			durationInMinutes: 24,
			circumstances: "Some other circumstances."
		)

		guard let locationVisit = fetchEntries(for: "LocationVisit", with: locationVisitId, from: databaseQueue),
			  let date = locationVisit.string(forColumn: "date"),
			  let circumstances = locationVisit.string(forColumn: "circumstances")
		else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		let durationInMinutes = Int(locationVisit.int(forColumn: "durationInMinutes"))

		let fetchedLocationId = Int(locationVisit.int(forColumn: "locationId"))

		XCTAssertEqual(date, "2020-12-11")
		XCTAssertEqual(fetchedLocationId, locationId)
		XCTAssertEqual(circumstances, "Some other circumstances.")
		XCTAssertEqual(durationInMinutes, 24)
	}

	func test_When_updateContactPerson_Then_ContactPersonIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addContactPerson(
			name: "Helge Schneider",
			phoneNumber: "123456",
			emailAddress: "some@mail.de"
		)

		guard case let .success(id) = result else {
			XCTFail("Failed to add ContactPerson")
			return
		}

		let updateResult = store.updateContactPerson(
			id: id,
			name: "Updated Name",
			phoneNumber: "45678",
			emailAddress: "other@mail.de"
		)

		guard case .success = updateResult else {
			XCTFail("Failed to update ContactPerson")
			return
		}

		guard let contactPerson = fetchEntries(for: "ContactPerson", with: id, from: databaseQueue),
			  let name = contactPerson.string(forColumn: "name"),
			  let phoneNumber = contactPerson.string(forColumn: "phoneNumber"),
			  let emailAddress = contactPerson.string(forColumn: "emailAddress") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
		XCTAssertEqual(phoneNumber, "45678")
		XCTAssertEqual(emailAddress, "other@mail.de")
	}

	func test_When_updateLocation_Then_LocationIsUpdated() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		let result = store.addLocation(
			name: "Woanders",
			phoneNumber: "123456",
			emailAddress: "some@mail.de",
			traceLocationGUID: nil
		)

		guard case let .success(id) = result else {
			XCTFail("Failed to add Location")
			return
		}

		let updateResult = store.updateLocation(
			id: id,
			name: "Updated Name",
			phoneNumber: "45678",
			emailAddress: "other@mail.de"
		)

		guard case .success = updateResult else {
			XCTFail("Failed to update Location")
			return
		}

		guard let location = fetchEntries(for: "Location", with: id, from: databaseQueue),
			  let name = location.string(forColumn: "name"),
			  let phoneNumber = location.string(forColumn: "phoneNumber"),
			  let emailAddress = location.string(forColumn: "emailAddress") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, "Updated Name")
		XCTAssertEqual(phoneNumber, "45678")
		XCTAssertEqual(emailAddress, "other@mail.de")
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
			// Only the userVisiblePeriodInDays should be returned.
			XCTAssertEqual(diaryDays.count, store.userVisiblePeriodInDays)

			XCTAssertEqual(diaryDays[0].formattedDate, "Donnerstag, 31.12.20")
		}.store(in: &subscriptions)
	}

	func test_When_sinkOnDiaryDays_Then_diaryDaysWithCorrectEntriesAreReturned() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)
		let tenDays = 10
		let daysVisible = store.userVisiblePeriodInDays
		let daysRetention = store.dataRetentionPeriodInDays

		let today = Date()

		guard daysVisible > tenDays,
			  let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -tenDays, to: today),
			  let daysVisibleMinusOne = Calendar.current.date(byAdding: .day, value: -(daysVisible - 1), to: today),
			  let retensionDate = Calendar.current.date(byAdding: .day, value: -daysRetention, to: today) else {
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

		// tenDaysAgoDate
		addLocationVisit(locationId: kincardineLocationId, date: tenDaysAgo, store: store)
		addPersonEncounter(personId: maryBarryPersonId, date: tenDaysAgo, store: store)

		// daysVisibleMinusOne ago (should not be persisted)
		addPersonEncounter(personId: maryBarryPersonId, date: daysVisibleMinusOne, store: store)
		addPersonEncounter(personId: emmaHicksPersonId, date: daysVisibleMinusOne, store: store)

		// retensionDate ago (should not be persisted)
		addLocationVisit(locationId: kincardineLocationId, date: retensionDate, store: store)
		addLocationVisit(locationId: conistonLocationId, date: retensionDate, store: store)

		store.diaryDaysPublisher.sink { diaryDays in
			// Only the last daysVisible (including today) should be returned.
			XCTAssertEqual(diaryDays.count, daysVisible)

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
			let tenDaysAgoDiaryDay = diaryDays[tenDays]

			self.checkPersonEntry(entry: tenDaysAgoDiaryDay.entries[0], name: "Emma Hicks", id: emmaHicksPersonId, isSelected: false)
			self.checkPersonEntry(entry: tenDaysAgoDiaryDay.entries[1], name: "Mary Barry", id: maryBarryPersonId, isSelected: true)

			self.checkLocationEntry(entry: tenDaysAgoDiaryDay.entries[2], name: "Coniston", id: conistonLocationId, isSelected: false)
			self.checkLocationEntry(entry: tenDaysAgoDiaryDay.entries[3], name: "Kincardine", id: kincardineLocationId, isSelected: true)

			// Test the data for daysVisible - 1 days ago
			let fourteenDaysAgoDiaryDay = diaryDays[daysVisible - 1]
			self.checkPersonEntry(entry: fourteenDaysAgoDiaryDay.entries[0], name: "Emma Hicks", id: emmaHicksPersonId, isSelected: true)
			self.checkPersonEntry(entry: fourteenDaysAgoDiaryDay.entries[1], name: "Mary Barry", id: maryBarryPersonId, isSelected: true)

			self.checkLocationEntry(entry: fourteenDaysAgoDiaryDay.entries[2], name: "Coniston", id: conistonLocationId, isSelected: false)
			self.checkLocationEntry(entry: fourteenDaysAgoDiaryDay.entries[3], name: "Kincardine", id: kincardineLocationId, isSelected: false)

		}.store(in: &subscriptions)
	}

	func test_When_cleanupIsCalled_Then_EntriesOlderThenRetentionDaysAreDeleted() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)
		let daysRetention = store.dataRetentionPeriodInDays

		let today = Date()

		guard let daysRetentionAgoDate = Calendar.current.date(byAdding: .day, value: -(daysRetention + 1), to: today) else {
			fatalError("Could not create test dates.")
		}

		let emmaHicksPersonId = addContactPerson(name: "Emma Hicks", to: store)
		let kincardineLocationId = addLocation(name: "Kincardine", to: store)

		let personEncounterId = addPersonEncounter(personId: emmaHicksPersonId, date: daysRetentionAgoDate, store: store)
		let locationVisitId = addLocationVisit(locationId: kincardineLocationId, date: daysRetentionAgoDate, store: store)

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

		let updateResult = store.updateContactPerson(id: personId, name: stringWith251Chars, phoneNumber: "", emailAddress: "")

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

		let updateResult = store.updateLocation(id: locationId, name: stringWith251Chars, phoneNumber: "", emailAddress: "")

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

		let dateProviderStub = DateProviderStub(today: today)
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue, dateProvider: dateProviderStub)

		let tenDays = 10
		let daysVisible = store.userVisiblePeriodInDays

		guard daysVisible > tenDays,
			  let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -tenDays, to: today),
			  let daysVisibleAgo = Calendar.current.date(byAdding: .day, value: -(daysVisible - 1), to: today) else {
			fatalError("Could not create test dates.")
		}

		let adamSandaleId = addContactPerson(name: "Adam Sandale", phoneNumber: "123456", eMail: "some@mail.de", to: store)
		let emmaHicksId = addContactPerson(name: "Emma Hicks", to: store)

		let amsterdamLocationId = addLocation(name: "Amsterdam", phoneNumber: "12345678", eMail: "mail@amster.dam", to: store)
		let berlinId = addLocation(name: "Berlin", to: store)

		addLocationVisit(locationId: amsterdamLocationId, date: today, store: store)
		addLocationVisit(locationId: berlinId, date: today, store: store)
		addPersonEncounter(personId: emmaHicksId, date: today, store: store)
		addPersonEncounter(
			personId: adamSandaleId,
			date: today,
			duration: .lessThan15Minutes,
			maskSituation: .withMask,
			setting: .inside,
			circumstances: "Some circumstances.",
			store: store
		)

		addLocationVisit(
			locationId: amsterdamLocationId,
			date: tenDaysAgo,
			durationInMinutes: 62,
			circumstances: "Some circumstances",
			store: store
		)
		addPersonEncounter(personId: emmaHicksId, date: tenDaysAgo, store: store)

		addLocationVisit(locationId: amsterdamLocationId, date: daysVisibleAgo, store: store)
		addLocationVisit(locationId: berlinId, date: daysVisibleAgo, store: store)
		addPersonEncounter(personId: emmaHicksId, date: daysVisibleAgo, store: store)
		addPersonEncounter(personId: adamSandaleId, date: daysVisibleAgo, store: store)

		let exportResult = store.export()
		guard case let .success(exportString) = exportResult else {
			XCTFail("Error not expected")
			return
		}

		let expectedString = """
			Kontakte der letzten \(daysVisible) Tage (01.12.2020 - 15.12.2020)
			Die nachfolgende Liste dient dem zuständigen Gesundheitsamt zur Kontaktnachverfolgung gem. § 25 IfSG.

			15.12.2020 Adam Sandale; Tel. 123456; eMail some@mail.de; Kontaktdauer < 15 Minuten; mit Maske; im Gebäude; Some circumstances.
			15.12.2020 Emma Hicks
			15.12.2020 Amsterdam; Tel. 12345678; eMail mail@amster.dam
			15.12.2020 Berlin
			05.12.2020 Emma Hicks
			05.12.2020 Amsterdam; Tel. 12345678; eMail mail@amster.dam; Dauer 01:02 h; Some circumstances
			01.12.2020 Adam Sandale; Tel. 123456; eMail some@mail.de
			01.12.2020 Emma Hicks
			01.12.2020 Amsterdam; Tel. 12345678; eMail mail@amster.dam
			01.12.2020 Berlin
			"""

		XCTAssertEqual(exportString, expectedString)
	}

	func test_When_Reset_Then_DatabaseIsEmpty() {
		let databaseQueue = makeDatabaseQueue()
		let store = makeContactDiaryStore(with: databaseQueue)

		databaseQueue.inDatabase { database in
			XCTAssertEqual(database.numberOfTables, 4, "Looks like there is a new table. Please extend this test and add the new table to the dropTables() function.")
		}

		// Add data and check if its persisted.

		let personId = addContactPerson(name: "Some Person", to: store)
		addPersonEncounter(personId: personId, date: Date(), store: store)
		let locationId = addLocation(name: "Some Location", to: store)
		addLocationVisit(locationId: locationId, date: Date(), store: store)

		XCTAssertNotNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPerson", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPersonEncounter", with: locationId, from: databaseQueue))

		// Reset store and check if date was removed.

		guard case .success = store.reset() else {
			XCTFail("Failure not expected.")
			return
		}

		let numberOfDiaryEntries = store.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfDiaryEntries, 0)

		XCTAssertNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "ContactPerson", with: locationId, from: databaseQueue))
		XCTAssertNil(fetchEntries(for: "ContactPersonEncounter", with: locationId, from: databaseQueue))

		// Add again some data an check if persistence is working again.

		let person1Id = addContactPerson(name: "Some Person", to: store)
		addPersonEncounter(personId: person1Id, date: Date(), store: store)
		let location1Id = addLocation(name: "Some Location", to: store)
		addLocationVisit(locationId: location1Id, date: Date(), store: store)

		XCTAssertNotNil(fetchEntries(for: "Location", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "LocationVisit", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPerson", with: locationId, from: databaseQueue))
		XCTAssertNotNil(fetchEntries(for: "ContactPersonEncounter", with: locationId, from: databaseQueue))
	}

	func test_when_storeIsCorrupted_then_makeDeletesAndRecreatesStore() throws {
		let tempDatabaseURL = try makeTempDatabaseURL()
		let store = ContactDiaryStore.make(url: tempDatabaseURL)
		_ = store.addContactPerson(name: "Some Name")
		let daysVisible = store.userVisiblePeriodInDays

		let numberOfEntries = store.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfEntries, daysVisible)
		store.close()

		do {
			let corruptingString = "I will corrupt the database"
			try corruptingString.write(to: tempDatabaseURL, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			XCTFail("Error is not expected: \(error)")
		}

		let storeAfterRescue = ContactDiaryStore.make(url: tempDatabaseURL)
		_ = storeAfterRescue.addContactPerson(name: "Some Name")
		let numberOfEntriesAfterRescue = storeAfterRescue.diaryDaysPublisher.value.reduce(0) { $0 + $1.entries.count }
		XCTAssertEqual(numberOfEntriesAfterRescue, daysVisible)
	}

	func test_when_DatabaseUserVersionIs0_then_SchemaCreateIsCalled_and_MigrateIsNOTCalled() {
		let databaseQueue = makeDatabaseQueue()
		let schemaSpy = ContactDiarySchemaSpy(databaseQueue: databaseQueue)
		let migratorSpy = MigratorSpy(queue: databaseQueue, latestVersion: 0, migrations: [])

		_ = makeContactDiaryStore(with: databaseQueue, schema: schemaSpy, migrator: migratorSpy)

		XCTAssertTrue(schemaSpy.createWasCalled)
		XCTAssertFalse(migratorSpy.migrateWasCalled)
	}

	func test_when_DatabaseUserVersionIsNot0_then_MigrationIsCalled_and_SchemaCreateIsNOTCalled() throws {

		let tempDatabaseURL = try makeTempDatabaseURL()

		guard let databaseQueue = FMDatabaseQueue(path: tempDatabaseURL.path) else {
			XCTFail("Could not create FMDatabaseQueue.")
			return
		}

		// Create database with schemaV4. This will set userVersion to 4.
		let schemaV4 = ContactDiaryStoreSchemaV4(databaseQueue: databaseQueue)
		_ = makeContactDiaryStore(with: databaseQueue, schema: schemaV4)

		let schemaSpy = ContactDiarySchemaSpy(databaseQueue: databaseQueue)
		let migratorSpy = MigratorSpy(
			queue: databaseQueue,
			latestVersion: 4,
			migrations: [FakeMigration()]
		)

		// Close and create database again.
		// This time, migrator should be called, because a schema was allready created before and userVersion is >0.

		databaseQueue.close()

		_ = makeContactDiaryStore(with: databaseQueue, schema: schemaSpy, migrator: migratorSpy)

		XCTAssertFalse(schemaSpy.createWasCalled)
		XCTAssertTrue(migratorSpy.migrateWasCalled)
	}

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
	private func addContactPerson(
		name: String,
		phoneNumber: String = "",
		eMail: String = "",
		to store: ContactDiaryStore
	) -> Int {
		let addContactPersonResult = store.addContactPerson(name: name, phoneNumber: phoneNumber, emailAddress: eMail)
		guard case let .success(contactPersonId) = addContactPersonResult else {
			fatalError("Failed to add ContactPerson")
		}
		return contactPersonId
	}

	@discardableResult
	private func addLocation(
		name: String,
		phoneNumber: String = "",
		eMail: String = "",
		to store: ContactDiaryStore
	) -> Int {
		let addLocationResult = store.addLocation(name: name, phoneNumber: phoneNumber, emailAddress: eMail, traceLocationGUID: nil)
		guard case let .success(locationId) = addLocationResult else {
			fatalError("Failed to add Location")
		}
		return locationId
	}

	@discardableResult
	private func addLocationVisit(
		locationId: Int,
		date: Date,
		durationInMinutes: Int = 0,
		circumstances: String = "",
		store: ContactDiaryStore
	) -> Int {
		let dateString = dateFormatter.string(from: date)
		let addLocationVisitResult = store.addLocationVisit(
			locationId: locationId,
			date: dateString,
			durationInMinutes: durationInMinutes,
			circumstances: circumstances,
			checkinId: nil
		)
		guard case let .success(locationVisitId) = addLocationVisitResult else {
			fatalError("Failed to add LocationVisit")
		}
		return locationVisitId
	}

	@discardableResult
	private func addPersonEncounter(
		personId: Int,
		date: Date,
		duration: ContactPersonEncounter.Duration = .none,
		maskSituation: ContactPersonEncounter.MaskSituation = .none,
		setting: ContactPersonEncounter.Setting = .none,
		circumstances: String = "",
		store: ContactDiaryStore
	) -> Int {

		let dateString = dateFormatter.string(from: date)
		let addEncounterResult = store.addContactPersonEncounter(
			contactPersonId: personId,
			date: dateString,
			duration: duration,
			maskSituation: maskSituation,
			setting: setting,
			circumstances: circumstances
		)
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

	private func makeContactDiaryStore(
		with databaseQueue: FMDatabaseQueue,
		dateProvider: DateProviding = DateProvider(),
		schema: StoreSchemaProtocol? = nil,
		migrator: SerialMigratorProtocol? = nil
	) -> ContactDiaryStore {

		let _schema: StoreSchemaProtocol
		if let schema = schema {
			_schema = schema
		} else {
			_schema = ContactDiaryStoreSchemaV4(databaseQueue: databaseQueue)
		}

		let _migrator: SerialMigratorProtocol
		if let migrator = migrator {
			_migrator = migrator
		} else {
			_migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: 4, migrations: [])
		}

		guard let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: _schema,
			key: "Dummy",
			dateProvider: dateProvider,
			migrator: _migrator
		) else {
			fatalError("Could not create content diary store.")
		}

		return store
	}

	private func makeTempDatabaseURL() throws -> URL {
		let databaseBaseURL = FileManager.default.temporaryDirectory
			.appendingPathComponent("ContactDiaryStoreTests")

		try FileManager.default.createDirectory(
			at: databaseBaseURL,
			withIntermediateDirectories: true,
			attributes: nil
		)

		let databaseURL = databaseBaseURL
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("sqlite")

		return databaseURL
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

}

struct DateProviderStub: DateProviding {
	var today: Date

}

private class FakeMigration: Migration {
	var version = 4
	func execute() throws { }
}

private class MigratorSpy: SerialDatabaseQueueMigrator {
	var migrateWasCalled = false

	override func migrate() throws {
		try super.migrate()
		migrateWasCalled = true
	}
}

private class ContactDiarySchemaSpy: ContactDiaryStoreSchemaV4 {
	var createWasCalled = false

	override func create() -> SecureSQLStore.VoidResult {
		super.create()
		createWasCalled = true
		return .success(())
	}

	// swiftlint:disable:next file_length
}
