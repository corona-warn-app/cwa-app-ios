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

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding

protocol DiaryStoring {

	typealias DiaryStoringResult = Result<Int, SQLiteErrorCode>
	typealias DiaryStoringVoidResult = Result<Void, SQLiteErrorCode>

	@discardableResult
	func addContactPerson(name: String) -> DiaryStoringResult
	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult
	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult

	@discardableResult
	func updateContactPerson(id: Int, name: String) -> DiaryStoringVoidResult
	@discardableResult
	func updateLocation(id: Int, name: String) -> DiaryStoringVoidResult

	@discardableResult
	func removeContactPerson(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeLocation(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeContactPersonEncounter(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeLocationVisit(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeAllLocations() -> DiaryStoringVoidResult
	@discardableResult
	func removeAllContactPersons() -> DiaryStoringVoidResult
	@discardableResult
	func cleanup() -> DiaryStoringVoidResult
}

protocol DiaryProviding {

	var diaryDaysPublisher: CurrentValueSubject<[DiaryDay], Never> { get }
}

class MockDiaryStore: DiaryStoringProviding {

	// MARK: - Init

	init() {
		updateDays()
	}

	// MARK: - Protocol DiaryStoring

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	@discardableResult
	func addContactPerson(name: String) -> DiaryStoringResult {
		let id = contactPersons.map { $0.id }.max() ?? -1 + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult {
		let id = locations.map { $0.id }.max() ?? -1 + 1
		locations.append(DiaryLocation(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult {
		let id = contactPersonEncounters.map { $0.id }.max() ?? -1 + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult {
		let id = locationVisits.map { $0.id }.max() ?? -1 + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId))

		updateDays()

		return .success(id)
	}

	func updateContactPerson(id: Int, name: String) -> DiaryStoringVoidResult {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersons[index] = DiaryContactPerson(id: id, name: name)

		updateDays()

		return .success(())
	}

	func updateLocation(id: Int, name: String) -> DiaryStoringVoidResult {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locations[index] = DiaryLocation(id: id, name: name)

		updateDays()

		return .success(())
	}

	func removeContactPerson(id: Int) -> DiaryStoringVoidResult {
		contactPersons.removeAll { $0.id == id }
		contactPersonEncounters.removeAll { $0.contactPersonId == id }

		updateDays()

		return .success(())
	}

	func removeLocation(id: Int) -> DiaryStoringVoidResult {
		locations.removeAll { $0.id == id }
		locationVisits.removeAll { $0.locationId == id }

		updateDays()

		return .success(())
	}

	func removeContactPersonEncounter(id: Int) -> DiaryStoringVoidResult {
		contactPersonEncounters.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeLocationVisit(id: Int) -> DiaryStoringVoidResult {
		locationVisits.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeAllLocations() -> DiaryStoringVoidResult {
		locations.removeAll()
		locationVisits.removeAll()

		updateDays()

		return .success(())
	}

	func removeAllContactPersons() -> DiaryStoringVoidResult {
		contactPersons.removeAll()
		contactPersonEncounters.removeAll()

		updateDays()

		return .success(())
	}

	func cleanup() -> DiaryStoringVoidResult {
		// There is no cleanup implemented (deleting old entries) for the mock.
		return .success(())
	}

	// MARK: - Private

	private var contactPersons = [
		DiaryContactPerson(id: 0, name: "Andreas"),
		DiaryContactPerson(id: 1, name: "Marcus"),
		DiaryContactPerson(id: 2, name: "Carsten"),
		DiaryContactPerson(id: 3, name: "Artur"),
		DiaryContactPerson(id: 4, name: "Karsten"),
		DiaryContactPerson(id: 5, name: "Kai"),
		DiaryContactPerson(id: 6, name: "Nick"),
		DiaryContactPerson(id: 7, name: "Omar"),
		DiaryContactPerson(id: 8, name: "Pascal"),
		DiaryContactPerson(id: 9, name: "Puneet")
	]

	private var locations = [
		DiaryLocation(id: 0, name: "Supermarkt"),
		DiaryLocation(id: 1, name: "Bäckerei")
	]

	private var contactPersonEncounters = [
		ContactPersonEncounter(id: 0, date: "2020-12-09", contactPersonId: 5),
		ContactPersonEncounter(id: 1, date: "2020-12-09", contactPersonId: 1),
		ContactPersonEncounter(id: 2, date: "2020-12-09", contactPersonId: 3),
		ContactPersonEncounter(id: 3, date: "2020-12-07", contactPersonId: 8)
	]

	private var locationVisits = [
		LocationVisit(id: 0, date: "2020-12-09", locationId: 1),
		LocationVisit(id: 1, date: "2020-12-08", locationId: 0)
	]

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

	init(store: DiaryStoringProviding) {
		self.store = store

		store.diaryDaysPublisher.sink { [weak self] in
			self?.days = $0
		}.store(in: &subscriptions)
	}

	// MARK: - Internal
	
	let store: DiaryStoringProviding

	@Published private(set) var days: [DiaryDay] = []

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

class DiaryDayService {

	// MARK: - Init

	init(day: DiaryDay, store: DiaryStoringProviding) {
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

	private let store: DiaryStoringProviding

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

	var selectedEntries: [DiaryEntry] {
		entries.filter {
			switch $0 {
			case .location(let location):
				return location.visitId != nil
			case .contactPerson(let contactPerson):
				return contactPerson.encounterId != nil
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
