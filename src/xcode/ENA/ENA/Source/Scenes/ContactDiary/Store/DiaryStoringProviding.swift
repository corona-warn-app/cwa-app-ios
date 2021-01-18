////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding

enum DiaryStoringError: Error {
	case database(SQLiteErrorCode)
	case timeout
}

protocol DiaryStoring {

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
	func addRiskLevelPerDate(_ riskLevelPerDate: [Date: RiskLevel]) -> DiaryStoringResult

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
