////
// 🦠 Corona-Warn-App
//

import Foundation

struct ContactPersonEncounter {
	let id: Int
	let date: String
	let contactPersonId: Int
}

struct LocationVisit {
	let id: Int
	let date: String
	let locationId: Int
}

protocol DiaryStoring {

	@discardableResult
	func addContactPerson(name: String) -> Int
	@discardableResult
	func addLocation(name: String) -> Int
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> Int
	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> Int

	func updateContactPerson(id: Int, name: String)
	func updateLocation(id: Int, name: String)

	func removeContactPerson(id: Int)
	func removeLocation(id: Int)
	func removeContactPersonEncounter(id: Int)
	func removeLocationVisit(id: Int)
	func removeAllLocations()
	func removeAllContactPersons()

	func fetchDays() -> [DiaryDay]

}

class MockDiaryStore: DiaryStoring {

	// MARK: - Protocol DiaryStoring

	@discardableResult
	func addContactPerson(name: String) -> Int {
		let id = contactPersons.map { $0.id }.max() ?? -1 + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name))

		return id
	}

	@discardableResult
	func addLocation(name: String) -> Int {
		let id = locations.map { $0.id }.max() ?? -1 + 1
		locations.append(DiaryLocation(id: id, name: name))

		return id
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> Int {
		let id = contactPersonEncounters.map { $0.id }.max() ?? -1 + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId))

		return id
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> Int {
		let id = locationVisits.map { $0.id }.max() ?? -1 + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId))

		return id
	}

	func updateContactPerson(id: Int, name: String) {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return }
		contactPersons[index] = DiaryContactPerson(id: id, name: name)
	}

	func updateLocation(id: Int, name: String) {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return }
		locations[index] = DiaryLocation(id: id, name: name)
	}

	func removeContactPerson(id: Int) {
		contactPersons.removeAll { $0.id == id }
	}

	func removeLocation(id: Int) {
		locations.removeAll { $0.id == id }
	}

	func removeContactPersonEncounter(id: Int) {
		contactPersonEncounters.removeAll { $0.id == id }
	}

	func removeLocationVisit(id: Int) {
		locationVisits.removeAll { $0.id == id }
	}

	func removeAllLocations() {
		locations.removeAll()
	}

	func removeAllContactPersons() {
		contactPersons.removeAll()
	}

	func fetchDays() -> [DiaryDay] {

		var diaryDays = [DiaryDay]()

		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		for dayDifference in 0...14 {
			guard let date = Calendar.current.date(byAdding: .day, value: -dayDifference, to: Date()) else { continue }
			let dateString = dateFormatter.string(from: date)

			let contactPersonEntries = contactPersons.map { contactPerson -> DiaryEntry in
				let encounterId = contactPersonEncounters.first { $0.date == dateString && $0.contactPersonId == contactPerson.id }?.id

				let contactPerson = DiaryContactPerson(id: contactPerson.id, name: contactPerson.name, encounterId: encounterId)
				return DiaryEntry.contactPerson(contactPerson)
			}

			let locationEntries = locations.map { location -> DiaryEntry in
				let visitId = locationVisits.first { $0.date == dateString && $0.locationId == location.id }?.id

				let location = DiaryLocation(id: location.id, name: location.name, visitId: visitId)
				return DiaryEntry.location(location)
			}

			diaryDays.append(DiaryDay(dateString: dateString, entries: contactPersonEntries + locationEntries))
		}

		return diaryDays
	}

	// MARK: - Private

	private var contactPersons = [DiaryContactPerson]()
	private var locations = [DiaryLocation]()

	private var contactPersonEncounters = [ContactPersonEncounter]()
	private var locationVisits = [LocationVisit]()

}


class DiaryService {

	// MARK: - Init

	init(store: DiaryStoring) {
		self.store = store
	}

	// MARK: - Internal

	@Published private(set) var days: [DiaryDay] = []

	func update(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.updateLocation(id: location.id, name: location.name)
		case .contactPerson(let contactPerson):
			store.updateContactPerson(id: contactPerson.id, name: contactPerson.name)
		}
	}

	func remove(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.removeLocation(id: location.id)
		case .contactPerson(let contactPerson):
			store.removeContactPerson(id: contactPerson.id)
		}
	}

	func removeAll(entryType: DiaryEntryType) {
		switch entryType {
		case .location:
			store.removeAllLocations()
		case .contactPerson:
			store.removeAllContactPersons()
		}
	}

	func removeObsoleteDays() {}

	// MARK: - Private

	private let store: DiaryStoring

}

class DiaryDayService {

	// MARK: - Init

	init(day: DiaryDay, store: DiaryStoring) {
		self.day = day
		self.store = store
	}

	// MARK: - Internal

	func select(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.addLocationVisit(locationId: location.id, date: day.dateString)
		case .contactPerson(let contactPerson):
			store.addContactPersonEncounter(contactPersonId: contactPerson.id, date: day.dateString)
		}
	}

	func deselect(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			guard let visitId = location.visitId else {
				Log.error("Trying to deselect unselected location", log: .contactdiary)
				return
			}
			store.removeLocationVisit(id: visitId)
		case .contactPerson(let contactPerson):
			guard let encounterId = contactPerson.encounterId else {
				Log.error("Trying to deselect unselected contact person", log: .contactdiary)
				return
			}
			store.removeContactPersonEncounter(id: encounterId)
		}
	}

	func add(entry: DiaryEntry.New) {
		switch entry {
		case .location(let location):
			let id = store.addLocation(name: location.name)
			store.addLocationVisit(locationId: id, date: day.dateString)
		case .contactPerson(let contactPerson):
			let id = store.addContactPerson(name: contactPerson.name)
			store.addContactPersonEncounter(contactPersonId: id, date: day.dateString)
		}
	}

	// MARK: - Private

	private let day: DiaryDay
	private let store: DiaryStoring

}

class DiaryDay {

	// MARK: - Init

	init(
		dateString: String,
		entries: [DiaryEntry]
	) {
		self.dateString = dateString
		self.entries = entries
	}

	// MARK: - Internal

	let dateString: String

	@Published private(set) var entries: [DiaryEntry]

	var date: Date {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

}

enum DiaryEntryType {

	// MARK: - Internal

	case location
	case contactPerson

}

enum DiaryEntry {

	enum New {

		// MARK: - Internal

		case location(DiaryLocation.New)
		case contactPerson(DiaryContactPerson.New)

	}

	// MARK: - Internal

	case location(DiaryLocation)
	case contactPerson(DiaryContactPerson)

	var isSelected: Bool {
		switch self {
		case .location(let location):
			return location.visitId != nil
		case .contactPerson(let contactPerson):
			return contactPerson.encounterId != nil
		}
	}

}

struct DiaryLocation {

	struct New {

		// MARK: - Internal

		let name: String

	}

	// MARK: - Init

	init(id: Int, name: String, visitId: Int? = nil) {
		self.id = id
		self.name = name
		self.visitId = visitId
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let visitId: Int?

}

struct DiaryContactPerson {

	struct New {

		// MARK: - Internal

		let name: String

	}

	// MARK: - Init

	init(id: Int, name: String, encounterId: Int? = nil) {
		self.id = id
		self.name = name
		self.encounterId = encounterId
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let encounterId: Int?

}
