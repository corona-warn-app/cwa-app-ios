//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryContactPersonTest: XCTestCase {

	func testUnselectedContactPerson() throws {
		let contactPerson = DiaryContactPerson(id: 0, name: "Joachim Yogi Fritsch")

		XCTAssertEqual(contactPerson.id, 0)
		XCTAssertEqual(contactPerson.name, "Joachim Yogi Fritsch")
		XCTAssertNil(contactPerson.encounterId)
		XCTAssertFalse(contactPerson.isSelected)
	}

	func testSelectedContactPerson() throws {
		let contactPerson = DiaryContactPerson(id: 0, name: "Maximilian Lenkeit", encounterId: 17)

		XCTAssertEqual(contactPerson.id, 0)
		XCTAssertEqual(contactPerson.name, "Maximilian Lenkeit")
		XCTAssertEqual(contactPerson.encounterId, 17)
		XCTAssertTrue(contactPerson.isSelected)
	}
	
}
