//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryEntryTest: XCTestCase {

	func testUnselectedContactPerson() throws {
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Joachim Yogi Fritsch"))

		XCTAssertEqual(entry.name, "Joachim Yogi Fritsch")
		XCTAssertFalse(entry.isSelected)
		XCTAssertEqual(entry.type, .contactPerson)
	}

	func testSelectedContactPerson() throws {
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Maximilian Lenkeit", encounterId: 17))

		XCTAssertEqual(entry.name, "Maximilian Lenkeit")
		XCTAssertTrue(entry.isSelected)
		XCTAssertEqual(entry.type, .contactPerson)
	}

	func testUnselectedLocation() throws {
		let entry: DiaryEntry = .location(DiaryLocation(id: 0, name: "Mars"))

		XCTAssertEqual(entry.name, "Mars")
		XCTAssertFalse(entry.isSelected)
		XCTAssertEqual(entry.type, .location)
	}

	func testSelectedLocation() throws {
		let entry: DiaryEntry = .location(DiaryLocation(id: 0, name: "Earth", visitId: 17))

		XCTAssertEqual(entry.name, "Earth")
		XCTAssertTrue(entry.isSelected)
		XCTAssertEqual(entry.type, .location)
	}
	
}
