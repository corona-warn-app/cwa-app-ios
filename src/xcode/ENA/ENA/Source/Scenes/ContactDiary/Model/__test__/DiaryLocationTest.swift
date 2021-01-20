//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryLocationTest: XCTestCase {

	func testUnselectedContactPerson() throws {
		let location = DiaryLocation(id: 0, name: "Mars")

		XCTAssertEqual(location.id, 0)
		XCTAssertEqual(location.name, "Mars")
		XCTAssertNil(location.visitId)
		XCTAssertFalse(location.isSelected)
	}

	func testSelectedContactPerson() throws {
		let location = DiaryLocation(id: 0, name: "Earth", visitId: 17)

		XCTAssertEqual(location.id, 0)
		XCTAssertEqual(location.name, "Earth")
		XCTAssertEqual(location.visitId, 17)
		XCTAssertTrue(location.isSelected)
	}
	
}
