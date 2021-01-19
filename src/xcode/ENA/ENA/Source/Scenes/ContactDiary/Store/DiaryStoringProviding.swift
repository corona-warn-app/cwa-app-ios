////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

typealias DiaryStoring = DiaryProvidingV3 & DiaryStoringV2 & DiaryStoringV3
typealias DiaryProviding = DiaryProvidingV3
typealias DiaryDay = DiaryDayV3
typealias ContactDiaryStore = ContactDiaryStoreV3

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding
typealias ContactDiaryStoreSchema = ContactDiaryStoreSchemaV3

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

protocol DiaryStoringV2 {

	typealias DiaryStoringResult = Result<Int, DiaryStoringError>
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

protocol DiaryStoringV3 {
	typealias DiaryStoringGroupResult = [Result<Int, DiaryStoringError>]

	@discardableResult
	func addRiskLevelPerDate(_ riskLevelPerDate: [Date: RiskLevel]) -> DiaryStoringGroupResult
}


protocol DiaryProvidingV2 {
	var diaryDaysPublisher: OpenCombine.CurrentValueSubject<[DiaryDayV2], Never> { get }
	func export() -> Result<String, SQLiteErrorCode>

}

protocol DiaryProvidingV3 {
	var diaryDaysPublisher: OpenCombine.CurrentValueSubject<[DiaryDayV3], Never> { get }
	func export() -> Result<String, SQLiteErrorCode>
}
