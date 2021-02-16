//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryLocationTest: XCTestCase {

	func testUnselectedLocation() throws {
		let location = DiaryLocation(
			id: 0,
			name: "Mars",
			phoneNumber: "999-999999999",
			emailAddress: "mars@universe.com"
		)

		XCTAssertEqual(location.id, 0)
		XCTAssertEqual(location.name, "Mars")
		XCTAssertEqual(location.phoneNumber, "999-999999999")
		XCTAssertEqual(location.emailAddress, "mars@universe.com")
		XCTAssertNil(location.visit)
		XCTAssertFalse(location.isSelected)
	}

	func testSelectedLocation() throws {
		let location = DiaryLocation(
			id: 0,
			name: "Earth",
			phoneNumber: "(11111) 11 1111111",
			emailAddress: "earth@universe.com",
			visit: LocationVisit(
				id: 17,
				date: "2021-02-11",
				locationId: 0,
				durationInMinutes: 90,
				circumstances: "Astronaut Training"
			)
		)

		XCTAssertEqual(location.id, 0)
		XCTAssertEqual(location.name, "Earth")
		XCTAssertEqual(location.phoneNumber, "(11111) 11 1111111")
		XCTAssertEqual(location.emailAddress, "earth@universe.com")
		XCTAssertEqual(location.visit?.id, 17)
		XCTAssertEqual(location.visit?.date, "2021-02-11")
		XCTAssertEqual(location.visit?.locationId, 0)
		XCTAssertEqual(location.visit?.durationInMinutes, 90)
		XCTAssertEqual(location.visit?.circumstances, "Astronaut Training")
		XCTAssertTrue(location.isSelected)
	}
	
}
