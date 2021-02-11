//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryEntryTest: XCTestCase {

	func testUnselectedContactPerson() throws {
		let entry: DiaryEntry = .contactPerson(
			DiaryContactPerson(
				id: 0,
				name: "Joachim Yogi Fritsch",
				phoneNumber: "12345",
				emailAddress: "mail@coronawarn.app"
			)
		)

		XCTAssertEqual(entry.name, "Joachim Yogi Fritsch")
		XCTAssertFalse(entry.isSelected)
		XCTAssertEqual(entry.type, .contactPerson)
	}

	func testSelectedContactPerson() throws {
		let entry: DiaryEntry = .contactPerson(
			DiaryContactPerson(
				id: 0,
				name: "Maximilian Lenkeit",
				phoneNumber: "98765",
				encounter: ContactPersonEncounter(
					id: 17,
					date: "2021-02-11",
					contactPersonId: 0
				)
			)
		)

		XCTAssertEqual(entry.name, "Maximilian Lenkeit")
		XCTAssertTrue(entry.isSelected)
		XCTAssertEqual(entry.type, .contactPerson)
	}

	func testUnselectedLocation() throws {
		let entry: DiaryEntry = .location(
			DiaryLocation(
				id: 0,
				name: "Mars",
				phoneNumber: "999-999999999",
				emailAddress: "mars@universe.com"
			)
		)

		XCTAssertEqual(entry.name, "Mars")
		XCTAssertFalse(entry.isSelected)
		XCTAssertEqual(entry.type, .location)
	}

	func testSelectedLocation() throws {
		let entry: DiaryEntry = .location(
			DiaryLocation(
				id: 0,
				name: "Earth",
				phoneNumber: "(11111) 11 1111111",
				emailAddress: "earth@universe.com",
				visit: LocationVisit(
					id: 17,
					date: "2021-02-11",
					locationId: 0,
					duration: 90,
					circumstances: "Astronaut Training"
				)
			)
		)

		XCTAssertEqual(entry.name, "Earth")
		XCTAssertTrue(entry.isSelected)
		XCTAssertEqual(entry.type, .location)
	}
	
}
