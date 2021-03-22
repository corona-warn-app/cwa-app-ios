////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding

protocol DiaryStoring {

	@discardableResult
	func addContactPerson(name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.IdResult
	@discardableResult
	func addLocation(name: String, phoneNumber: String, emailAddress: String, traceLocationGUID: String?) -> SecureSQLStore.IdResult
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> SecureSQLStore.IdResult
	@discardableResult
	func addLocationVisit(locationId: Int, date: String, durationInMinutes: Int, circumstances: String, checkinId: Int?) -> SecureSQLStore.IdResult

	@discardableResult
	func updateContactPerson(id: Int, name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.VoidResult
	@discardableResult
	func updateLocation(id: Int, name: String, phoneNumber: String, emailAddress: String) -> SecureSQLStore.VoidResult
	@discardableResult
	func updateContactPersonEncounter(id: Int, date: String, duration: ContactPersonEncounter.Duration, maskSituation: ContactPersonEncounter.MaskSituation, setting: ContactPersonEncounter.Setting, circumstances: String) -> SecureSQLStore.VoidResult
	@discardableResult
	func updateLocationVisit(id: Int, date: String, durationInMinutes: Int, circumstances: String) -> SecureSQLStore.VoidResult

	@discardableResult
	func removeContactPerson(id: Int) -> SecureSQLStore.VoidResult
	@discardableResult
	func removeLocation(id: Int) -> SecureSQLStore.VoidResult
	@discardableResult
	func removeContactPersonEncounter(id: Int) -> SecureSQLStore.VoidResult
	@discardableResult
	func removeLocationVisit(id: Int) -> SecureSQLStore.VoidResult
	@discardableResult
	func removeAllLocations() -> SecureSQLStore.VoidResult
	@discardableResult
	func removeAllContactPersons() -> SecureSQLStore.VoidResult
	@discardableResult
	func cleanup() -> SecureSQLStore.VoidResult
	@discardableResult
	func cleanup(timeout: TimeInterval) -> SecureSQLStore.VoidResult
	@discardableResult
	func reset() -> SecureSQLStore.VoidResult
	func close()

}

extension DiaryStoring {

	@discardableResult
	func addContactPerson(name: String) -> SecureSQLStore.IdResult {
		return addContactPerson(name: name, phoneNumber: "", emailAddress: "")
	}

	@discardableResult
	func addLocation(name: String) -> SecureSQLStore.IdResult {
		return addLocation(name: name, phoneNumber: "", emailAddress: "", traceLocationGUID: nil)
	}

	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> SecureSQLStore.IdResult {
		return addContactPersonEncounter(contactPersonId: contactPersonId, date: date, duration: .none, maskSituation: .none, setting: .none, circumstances: "")
	}

	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> SecureSQLStore.IdResult {
		return addLocationVisit(locationId: locationId, date: date, durationInMinutes: 0, circumstances: "", checkinId: nil)
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
