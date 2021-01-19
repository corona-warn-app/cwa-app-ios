////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding
typealias ContactDiaryStoreSchema = ContactDiaryStoreSchemaV3
typealias ContactDiaryStore = ContactDiaryStoreV3
typealias DiaryDay = DiaryDayV3

enum DiaryStoringError: Error {
	case database(SQLiteErrorCode)
	case timeout
}

struct DateProvider: DateProviding {
	var today: Date {
		Date()
	}
}

protocol DateProviding {
	var today: Date { get }
}

protocol DiaryStoring {

	typealias DiaryStoringResult = Result<Int, DiaryStoringError>
	typealias DiaryStoringGroupResult = [Result<Int, DiaryStoringError>]
	typealias DiaryStoringVoidResult = Result<Void, DiaryStoringError>

	@discardableResult
	func addContactPerson(name: String) -> DiaryStoringResult
	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult
	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult
	@discardableResult
	func addRiskLevelPerDate(_ riskLevelPerDate: [Date: RiskLevel]) -> DiaryStoringGroupResult

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
	@discardableResult
	func cleanup(timeout: TimeInterval) -> DiaryStoringVoidResult
	@discardableResult
	func reset() -> DiaryStoringVoidResult
	func close()
}

protocol DiaryProviding {

	var diaryDaysPublisher: OpenCombine.CurrentValueSubject<[DiaryDay], Never> { get }

	func export() -> Result<String, SQLiteErrorCode>
	
}
