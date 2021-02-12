//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryContactPersonTest: XCTestCase {

	func testUnselectedContactPerson() throws {
		let contactPerson = DiaryContactPerson(
			id: 0,
			name: "Joachim Yogi Fritsch",
			phoneNumber: "12345",
			emailAddress: "mail@coronawarn.app"
		)

		XCTAssertEqual(contactPerson.id, 0)
		XCTAssertEqual(contactPerson.name, "Joachim Yogi Fritsch")
		XCTAssertEqual(contactPerson.phoneNumber, "12345")
		XCTAssertEqual(contactPerson.emailAddress, "mail@coronawarn.app")
		XCTAssertNil(contactPerson.encounter)
		XCTAssertFalse(contactPerson.isSelected)
	}

	func testSelectedContactPerson() throws {
		let contactPerson = DiaryContactPerson(
			id: 0,
			name: "Maximilian Lenkeit",
			phoneNumber: "98765",
			emailAddress: "",
			encounter: ContactPersonEncounter(
				id: 17,
				date: "2021-02-11",
				contactPersonId: 0,
				duration: .moreThan15Minutes,
				maskSituation: .none,
				setting: .outside
			)
		)

		XCTAssertEqual(contactPerson.id, 0)
		XCTAssertEqual(contactPerson.name, "Maximilian Lenkeit")
		XCTAssertEqual(contactPerson.phoneNumber, "98765")
		XCTAssertEqual(contactPerson.emailAddress, "")
		XCTAssertEqual(contactPerson.encounter?.id, 17)
		XCTAssertEqual(contactPerson.encounter?.date, "2021-02-11")
		XCTAssertEqual(contactPerson.encounter?.contactPersonId, 0)
		XCTAssertEqual(contactPerson.encounter?.duration, .moreThan15Minutes)
		XCTAssertNil(contactPerson.encounter?.maskSituation)
		XCTAssertEqual(contactPerson.encounter?.setting, .outside)
		XCTAssertEqual(contactPerson.encounter?.circumstances, "")
		XCTAssertTrue(contactPerson.isSelected)
	}
	
}
