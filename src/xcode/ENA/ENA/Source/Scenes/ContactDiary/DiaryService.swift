////
// 🦠 Corona-Warn-App
//

import Foundation
import Combine

struct ContactPersonEncounter {
	let id: Int64
	let date: String
	let contactPersonId: Int64
}

struct LocationVisit {
	let id: Int64
	let date: String
	let locationId: Int64
}

protocol DiaryStoring {

	var diaryDaysPublisher: Published<[DiaryDay]>.Publisher { get }

	@discardableResult
	func addContactPerson(name: String) -> Result<Int64, SQLiteErrorCode>
	@discardableResult
	func addLocation(name: String) -> Result<Int64, SQLiteErrorCode>
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int64, date: String) -> Result<Int64, SQLiteErrorCode>
	@discardableResult
	func addLocationVisit(locationId: Int64, date: String) -> Result<Int64, SQLiteErrorCode>

	@discardableResult
	func updateContactPerson(id: Int64, name: String) -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func updateLocation(id: Int64, name: String) -> Result<Void, SQLiteErrorCode>

	@discardableResult
	func removeContactPerson(id: Int64) -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func removeLocation(id: Int64) -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func removeContactPersonEncounter(id: Int64) -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func removeLocationVisit(id: Int64) -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func removeAllLocations() -> Result<Void, SQLiteErrorCode>
	@discardableResult
	func removeAllContactPersons() -> Result<Void, SQLiteErrorCode>

}

class MockDiaryStore: DiaryStoring {

	// MARK: - Init

	init() {
		updateDays()
	}

	// MARK: - Protocol DiaryStoring

	var diaryDaysPublisher: Published<[DiaryDay]>.Publisher { $diaryDays }

	@discardableResult
	func addContactPerson(name: String) -> Result<Int64, SQLiteErrorCode> {
		let id = contactPersons.map { $0.id }.max() ?? -1 + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocation(name: String) -> Result<Int64, SQLiteErrorCode> {
		let id = locations.map { $0.id }.max() ?? -1 + 1
		locations.append(DiaryLocation(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int64, date: String) -> Result<Int64, SQLiteErrorCode> {
		let id = contactPersonEncounters.map { $0.id }.max() ?? -1 + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocationVisit(locationId: Int64, date: String) -> Result<Int64, SQLiteErrorCode> {
		let id = locationVisits.map { $0.id }.max() ?? -1 + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId))

		updateDays()

		return .success(id)
	}

	func updateContactPerson(id: Int64, name: String) -> Result<Void, SQLiteErrorCode> {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersons[index] = DiaryContactPerson(id: id, name: name)

		updateDays()

		return .success(())
	}

	func updateLocation(id: Int64, name: String) -> Result<Void, SQLiteErrorCode> {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locations[index] = DiaryLocation(id: id, name: name)

		updateDays()

		return .success(())
	}

	func removeContactPerson(id: Int64) -> Result<Void, SQLiteErrorCode> {
		contactPersons.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeLocation(id: Int64) -> Result<Void, SQLiteErrorCode> {
		locations.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeContactPersonEncounter(id: Int64) -> Result<Void, SQLiteErrorCode> {
		contactPersonEncounters.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeLocationVisit(id: Int64) -> Result<Void, SQLiteErrorCode> {
		locationVisits.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeAllLocations() -> Result<Void, SQLiteErrorCode> {
		locations.removeAll()

		updateDays()

		return .success(())
	}

	func removeAllContactPersons() -> Result<Void, SQLiteErrorCode> {
		contactPersons.removeAll()

		updateDays()

		return .success(())
	}

	// MARK: - Private

	@Published private var diaryDays: [DiaryDay] = []

	private var contactPersons = [DiaryContactPerson]()
	private var locations = [DiaryLocation]()

	private var contactPersonEncounters = [ContactPersonEncounter]()
	private var locationVisits = [LocationVisit]()

	private func updateDays() {
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

		self.diaryDays = diaryDays
	}

}


class DiaryService {

	// MARK: - Init

	init(store: DiaryStoring) {
		self.store = store

		store.diaryDaysPublisher.sink { [weak self] in
			self?.days = $0
		}.store(in: &subscriptions)
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

	private var subscriptions: [AnyCancellable] = []

}

class DiaryDayService {

	// MARK: - Init

	init(day: DiaryDay, store: DiaryStoring) {
		self.day = day
		self.store = store

		store.diaryDaysPublisher
			.sink { [weak self] days in
				guard let day = days.first(where: { $0.dateString == day.dateString }) else {
					return
				}

				self?.day = day
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	@Published private(set) var day: DiaryDay

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
			let result = store.addLocation(name: location.name)
			if case let .success(id) = result {
				store.addLocationVisit(locationId: id, date: day.dateString)
			}
		case .contactPerson(let contactPerson):
			let result = store.addContactPerson(name: contactPerson.name)
			if case let .success(id) = result {
				store.addContactPersonEncounter(contactPersonId: id, date: day.dateString)
			}
		}
	}

	// MARK: - Private

	private let store: DiaryStoring

	private var subscriptions: [AnyCancellable] = []

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

	init(id: Int64, name: String, visitId: Int64? = nil) {
		self.id = id
		self.name = name
		self.visitId = visitId
	}

	// MARK: - Internal

	let id: Int64
	let name: String
	let visitId: Int64?

}

struct DiaryContactPerson {

	struct New {

		// MARK: - Internal

		let name: String

	}

	// MARK: - Init

	init(id: Int64, name: String, encounterId: Int64? = nil) {
		self.id = id
		self.name = name
		self.encounterId = encounterId
	}

	// MARK: - Internal

	let id: Int64
	let name: String
	let encounterId: Int64?

}
