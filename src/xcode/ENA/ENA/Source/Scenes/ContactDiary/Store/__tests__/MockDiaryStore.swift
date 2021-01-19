////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

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
	func addContactPerson(name: String) -> DiaryStoringResult {
		let id = (contactPersons.map { $0.id }.max() ?? -1) + 1
		contactPersons.append(DiaryContactPerson(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult {
		let id = (locations.map { $0.id }.max() ?? -1) + 1
		locations.append(DiaryLocation(id: id, name: name))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult {
		let id = (contactPersonEncounters.map { $0.id }.max() ?? -1) + 1
		contactPersonEncounters.append(ContactPersonEncounter(id: id, date: date, contactPersonId: contactPersonId))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult {
		let id = (locationVisits.map { $0.id }.max() ?? -1) + 1
		locationVisits.append(LocationVisit(id: id, date: date, locationId: locationId))

		updateDays()

		return .success(id)
	}

	@discardableResult
	func addRiskLevelPerDate(_ riskLevelPerDate: [Date: RiskLevel]) -> DiaryStoringGroupResult {
		var groupResult: [Result<Int, DiaryStoringError>] = []

		for (date, riskLevel) in riskLevelPerDate {

			let id = (risklevelPerDays.map { $0.id }.max() ?? -1) + 1
			risklevelPerDays.append(RiskLevelPerDay(id: id, date: date, risklevel: riskLevel))
			groupResult.append(.success(id))
		}

		updateDays()

		return groupResult
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
	private var risklevelPerDays: [RiskLevelPerDay] = []

	private func updateDays() {
		var diaryDays = [DiaryDay]()

		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		for dayDifference in 0..<14 {
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

			let historyExposure: DiaryDay.HistoryExposure = risklevelPerDays
				.filter { dateFormatter.string(from: $0.date) == dateString }
				.map { $0.risklevel }
				.max()
				.map { .encounter($0) } ?? .none

			diaryDays.append(DiaryDay(
				dateString: dateString,
				entries: contactPersonEntries + locationEntries,
				historyExposure: historyExposure
			)
			)
		}

		diaryDaysPublisher.send(diaryDays)
	}

}

extension RiskLevel: Comparable {

	public static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}
