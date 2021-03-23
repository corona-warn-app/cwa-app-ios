////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
// CJE: Move back to ENATests target
// @testable import ENA

class MockDiaryStore: DiaryStoringProviding {

	// MARK: - Init

	init(
		dateProvider: DateProviding = DateProvider()
	) {
		self.dateProvider = dateProvider
		updateDays()
	}

	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = OpenCombine.CurrentValueSubject<[DiaryDay], Never>([])

	func export() -> Result<String, SQLiteErrorCode> {
		return .success("Dummy")
	}

	// MARK: - Protocol DiaryStoring

	@discardableResult
	func addContactPerson(name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.IdResult {
		let id = (contactPersons.map { $0.id }.max() ?? -1) + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocation(name: String, phoneNumber: String, emailAddress: String, traceLocationGUID: String?) -> SecureSQLStore.IdResult {
		let id = (locations.map { $0.id }.max() ?? -1) + 1
		locations.append(DiaryLocation(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, traceLocationGUID: traceLocationGUID))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> SecureSQLStore.IdResult {
		let id = (contactPersonEncounters.map { $0.id }.max() ?? -1) + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId, duration: duration, maskSituation: maskSituation, setting: setting, circumstances: circumstances))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String, durationInMinutes: Int, circumstances: String, checkinId: Int?) -> SecureSQLStore.IdResult {
		let id = (locationVisits.map { $0.id }.max() ?? -1) + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId, durationInMinutes: durationInMinutes, circumstances: circumstances, checkinId: checkinId))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func updateContactPerson(id: Int, name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.VoidResult {
		guard let index = contactPersons.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersons[index] = DiaryContactPerson(id: id, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateLocation(id: Int, name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.VoidResult {
		guard let index = locations.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locations[index] = DiaryLocation(
			id: id,
			name: name,
			phoneNumber: phoneNumber,
			emailAddress: emailAddress,
			traceLocationGUID: locations[index].traceLocationGUID
		)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateContactPersonEncounter(id: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> SecureSQLStore.VoidResult {
		guard let index = contactPersonEncounters.firstIndex(where: { $0.id == id }) else { return .success(()) }
		contactPersonEncounters[index] = ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonEncounters[index].contactPersonId, duration: duration, maskSituation: maskSituation, setting: setting, circumstances: circumstances)

		updateDays()

		return .success(())
	}

	@discardableResult
	func updateLocationVisit(id: Int, date: String, durationInMinutes: Int, circumstances: String) -> SecureSQLStore.VoidResult {
		guard let index = locationVisits.firstIndex(where: { $0.id == id }) else { return .success(()) }
		locationVisits[index] = LocationVisit(
			id: id,
			date: date,
			locationId: locationVisits[index].locationId,
			durationInMinutes: durationInMinutes,
			circumstances: circumstances,
			checkinId: locationVisits[index].checkinId
		)

		updateDays()

		return .success(())
	}

	func removeContactPerson(id: Int) -> SecureSQLStore.VoidResult {
		contactPersons.removeAll { $0.id == id }
		contactPersonEncounters.removeAll { $0.contactPersonId == id }

		updateDays()

		return .success(())
	}

	func removeLocation(id: Int) -> SecureSQLStore.VoidResult {
		locations.removeAll { $0.id == id }
		locationVisits.removeAll { $0.locationId == id }

		updateDays()

		return .success(())
	}

	func removeContactPersonEncounter(id: Int) -> SecureSQLStore.VoidResult {
		contactPersonEncounters.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	func removeLocationVisit(id: Int) -> SecureSQLStore.VoidResult {
		locationVisits.removeAll { $0.id == id }

		updateDays()

		return .success(())
	}

	@discardableResult
	func removeAllLocations() -> SecureSQLStore.VoidResult {
		locations.removeAll()
		locationVisits.removeAll()

		updateDays()

		return .success(())
	}
	
	@discardableResult
	func removeAllContactPersons() -> SecureSQLStore.VoidResult {
		contactPersons.removeAll()
		contactPersonEncounters.removeAll()

		updateDays()

		return .success(())
	}

	func cleanup() -> SecureSQLStore.VoidResult {
		// There is no cleanup implemented (deleting old entries) for the mock.
		return .success(())
	}

	func cleanup(timeout: TimeInterval) -> SecureSQLStore.VoidResult {
		// There is no cleanup implemented (deleting old entries) for the mock.
		return .success(())
	}

	@discardableResult
	func reset() -> SecureSQLStore.VoidResult {
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
	private let dateProvider: DateProviding

	private func updateDays() {
		var diaryDays = [DiaryDay]()

		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		for dayDifference in 0..<15 {
			guard let date = Calendar.current.date(byAdding: .day, value: -dayDifference, to: dateProvider.today) else { continue }
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

					let location = DiaryLocation(id: location.id, name: location.name, phoneNumber: location.phoneNumber, emailAddress: location.emailAddress, traceLocationGUID: location.traceLocationGUID, visit: visit)
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
