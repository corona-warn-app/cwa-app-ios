////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
// CJE: Move back to ENATests target
// @testable import ENA

class MockDiaryStore: DiaryStoringProviding {

	// MARK: - Init

	init() {
		updateDays()
	}

	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = OpenCombine.CurrentValueSubject<[DiaryDay], Never>([])

	func export() -> Result<String, SQLiteErrorCode> {
		return .success("Dummy")
	}

	// MARK: - Protocol DiaryStoring

	@discardableResult
	func addContactPerson(name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringResult {
		let id = (contactPersons.map { $0.id }.max() ?? -1) + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocation(name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringResult {
		let id = (locations.map { $0.id }.max() ?? -1) + 1
		locations.append(DiaryLocation(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> DiaryStoringResult {
		let id = (contactPersonEncounters.map { $0.id }.max() ?? -1) + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId, duration: duration, maskSituation: maskSituation, setting: setting, circumstances: circumstances))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String, duration: Int, circumstances: String) -> DiaryStoringResult {
		let id = (locationVisits.map { $0.id }.max() ?? -1) + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId, duration: duration, circumstances: circumstances))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func updateContactPerson(id: Int, name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringVoidResult {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersons[index] = DiaryContactPerson(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateLocation(id: Int, name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringVoidResult {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locations[index] = DiaryLocation(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateContactPersonEncounter(id: Int, contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> DiaryStoringVoidResult {
		guard let index = contactPersonEncounters.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersonEncounters[index] = ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId, duration: duration, maskSituation: maskSituation, setting: setting, circumstances: circumstances)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateLocationVisit(id: Int, locationId: Int, date: String, duration: Int, circumstances: String) -> DiaryStoringVoidResult {
		guard let index = locationVisits.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locationVisits[index] = LocationVisit(id: id, date: date, locationId: locationId, duration: duration, circumstances: circumstances)

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

	@discardableResult
	func removeAllLocations() -> DiaryStoringVoidResult {
		locations.removeAll()
		locationVisits.removeAll()

		updateDays()

		return .success(())
	}
	
	@discardableResult
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

	func cleanup(timeout: TimeInterval) -> DiaryStoringVoidResult {
		// There is no cleanup implemented (deleting old entries) for the mock.
		return .success(())
	}

	@discardableResult
	func reset() -> DiaryStoringVoidResult {
		contactPersons.removeAll()
		contactPersonEncounters.removeAll()
		locations.removeAll()
		locationVisits.removeAll()

		updateDays()
		return .success(())
	}

	func close() {
		reset()
	}

	// MARK: - Private

	private var contactPersons: [DiaryContactPerson] = []
	private var locations: [DiaryLocation] = []
	private var contactPersonEncounters: [ContactPersonEncounter] = []
	private var locationVisits: [LocationVisit] = []

	private func updateDays() {
		var diaryDays = [DiaryDay]()

		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		for dayDifference in 0..<15 {
			guard let date = Calendar.current.date(byAdding: .day, value: -dayDifference, to: Date()) else { continue }
			let dateString = dateFormatter.string(from: date)

			let contactPersonEntries = contactPersons
				.sorted { $0.name < $1.name }
				.map { contactPerson -> DiaryEntry in
					let encounter = contactPersonEncounters.first { $0.date == dateString && $0.contactPersonId == contactPerson.id }

					let contactPerson = DiaryContactPerson(id: contactPerson.id, name: contactPerson.name, phoneNumber: contactPerson.phoneNumber, emailAddress: contactPerson.emailAddress, encounter: encounter)
					return DiaryEntry.contactPerson(contactPerson)
				}

			let locationEntries = locations
				.sorted { $0.name < $1.name }
				.map { location -> DiaryEntry in
					let visit = locationVisits.first { $0.date == dateString && $0.locationId == location.id }

					let location = DiaryLocation(id: location.id, name: location.name, phoneNumber: location.phoneNumber, emailAddress: location.emailAddress, visit: visit)
					return DiaryEntry.location(location)
				}

			diaryDays.append(
				DiaryDay(
					dateString: dateString,
					entries: contactPersonEntries + locationEntries
				)
			)
		}

		diaryDaysPublisher.send(diaryDays)
	}

}
