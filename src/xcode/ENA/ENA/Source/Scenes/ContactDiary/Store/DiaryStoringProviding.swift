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
	func addContactPerson(name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringResult
	@discardableResult
	func addLocation(name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringResult
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, locationType: ContactPersonEncounter.LocationType, circumstances: String) -> DiaryStoringResult
	@discardableResult
	func addLocationVisit(locationId: Int, date: String, duration: Int, circumstances: String) -> DiaryStoringResult

	@discardableResult
	func updateContactPerson(id: Int, name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringVoidResult
	@discardableResult
	func updateLocation(id: Int, name: String, phoneNumber: String, emailAddress: String) -> DiaryStoringVoidResult
	@discardableResult
	func updateContactPersonEncounter(id: Int, contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, locationType: ContactPersonEncounter.LocationType, circumstances: String) -> DiaryStoringVoidResult
	@discardableResult
	func updateLocationVisit(id: Int, locationId: Int, date: String, duration: Int, circumstances: String) -> DiaryStoringVoidResult

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

extension DiaryStoring {

	@discardableResult
	func addContactPerson(name: String) -> DiaryStoringResult {
		return addContactPerson(name: name, phoneNumber: "", emailAddress: "")
	}

	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult {
		return addLocation(name: name, phoneNumber: "", emailAddress: "")
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult {
		return addContactPersonEncounter(contactPersonId: contactPersonId, date: date, duration: .none, maskSituation: .none, locationType: .none, circumstances: "")
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult {
		return addLocationVisit(locationId: locationId, date: date, duration: 0, circumstances: "")
	}

}

protocol DiaryProviding {

	var dataRetentionPeriodInDays: Int { get }
	var userVisiblePeriodInDays: Int { get }
	var diaryDaysPublisher: OpenCombine.CurrentValueSubject<[DiaryDay], Never> { get }

	func export() -> Result<String, SQLiteErrorCode>
	
}

/**
This extension provides a default implementation for the properties.
So we make sure to not declare the properties in any other implementations of this protocol, expecially in the unit tests. So the values are always the same.
*/

extension DiaryProviding {

	var dataRetentionPeriodInDays: Int { 17 } // Including today.
	var userVisiblePeriodInDays: Int { 15 } // Including today.

}
