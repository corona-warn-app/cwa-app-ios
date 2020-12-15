////
// 🦠 Corona-Warn-App
//

import Foundation
import Combine

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

	var diaryDaysPublisher: CurrentValueSubject<[DiaryDay], Never> { get }

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

}

class MockDiaryStore: DiaryStoring {

	// MARK: - Init

	init() {
		updateDays()
	}

	// MARK: - Protocol DiaryStoring

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	@discardableResult
	func addContactPerson(name: String) -> Int {
		let id = (contactPersons.map { $0.id }.max() ?? -1) + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name))

		updateDays()

		return id
	}

	@discardableResult
	func addLocation(name: String) -> Int {
		let id = (locations.map { $0.id }.max() ?? -1) + 1
		locations.append(DiaryLocation(id: id, name: name))

		updateDays()

		return id
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> Int {
		let id = (contactPersonEncounters.map { $0.id }.max() ?? -1) + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId))

		updateDays()

		return id
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> Int {
		let id = (locationVisits.map { $0.id }.max() ?? -1) + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId))

		updateDays()

		return id
	}

	func updateContactPerson(id: Int, name: String) {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return }
		contactPersons[index] = DiaryContactPerson(id: id, name: name)

		updateDays()
	}

	func updateLocation(id: Int, name: String) {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return }
		locations[index] = DiaryLocation(id: id, name: name)

		updateDays()
	}

	func removeContactPerson(id: Int) {
		contactPersons.removeAll { $0.id == id }
		contactPersonEncounters.removeAll { $0.contactPersonId == id }

		updateDays()
	}

	func removeLocation(id: Int) {
		locations.removeAll { $0.id == id }
		locationVisits.removeAll { $0.locationId == id }

		updateDays()
	}

	func removeContactPersonEncounter(id: Int) {
		contactPersonEncounters.removeAll { $0.id == id }

		updateDays()
	}

	func removeLocationVisit(id: Int) {
		locationVisits.removeAll { $0.id == id }

		updateDays()
	}

	func removeAllLocations() {
		locations.removeAll()
		locationVisits.removeAll()

		updateDays()
	}

	func removeAllContactPersons() {
		contactPersons.removeAll()
		contactPersonEncounters.removeAll()

		updateDays()
	}

	// MARK: - Private

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

			let contactPersonEntries = contactPersons
				.sorted { $0.name < $1.name }
				.map { contactPerson -> DiaryEntry in
					let encounterId = contactPersonEncounters.first { $0.date == dateString && $0.contactPersonId == contactPerson.id }?.id

					let contactPerson = DiaryContactPerson(id: contactPerson.id, name: contactPerson.name, encounterId: encounterId)
					return DiaryEntry.contactPerson(contactPerson)
				}

			let locationEntries = locations
				.sorted { $0.name < $1.name }
				.map { location -> DiaryEntry in
					let visitId = locationVisits.first { $0.date == dateString && $0.locationId == location.id }?.id

					let location = DiaryLocation(id: location.id, name: location.name, visitId: visitId)
					return DiaryEntry.location(location)
				}

			diaryDays.append(DiaryDay(dateString: dateString, entries: contactPersonEntries + locationEntries))
		}

		diaryDaysPublisher.send(diaryDays)
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

	let store: DiaryStoring

	var exportString: String {
		"These are your exported diary entries."
	}

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

	private var subscriptions: [AnyCancellable] = []

}

class DiaryDay: Equatable {

	// MARK: - Init

	init(
		dateString: String,
		entries: [DiaryEntry]
	) {
		self.dateString = dateString
		self.entries = entries
	}

	// MARK: - Protocol Equatable

	static func == (lhs: DiaryDay, rhs: DiaryDay) -> Bool {
		return lhs.dateString == rhs.dateString && lhs.entries == rhs.entries
	}

	// MARK: - Internal

	let dateString: String

	@Published private(set) var entries: [DiaryEntry]

	var selectedEntries: [DiaryEntry] {
		entries.filter {
			switch $0 {
			case .location(let location):
				return location.isSelected
			case .contactPerson(let contactPerson):
				return contactPerson.isSelected
			}
		}
	}

	var date: Date {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		guard let date = dateFormatter.date(from: dateString) else {
			Log.error("Could not get date from date string", log: .contactdiary)
			return Date()
		}

		return date
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEEddMMyy")

		return dateFormatter.string(from: date)
	}

}

enum DiaryEntryType {

	// MARK: - Internal

	case location
	case contactPerson

}

enum DiaryEntry: Equatable {

	enum New: Equatable {

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

	var type: DiaryEntryType {
		switch self {
		case .location:
			return .location
		case .contactPerson:
			return .contactPerson
		}
	}

}

struct DiaryLocation: Equatable {

	struct New: Equatable {

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

	var isSelected: Bool {
		visitId != nil
	}

}

struct DiaryContactPerson: Equatable {

	struct New: Equatable {

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

	var isSelected: Bool {
		encounterId != nil
	}

}
