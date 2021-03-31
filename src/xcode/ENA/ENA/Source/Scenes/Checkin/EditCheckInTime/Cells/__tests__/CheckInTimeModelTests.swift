////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import OpenCombine

class CheckInTimeModelTests: XCTestCase {

	func testGIVEN_CheckInTimeModel_WHEN_DateChanges_THEN_InitialPublisherSubmit() {
		// GIVEN
		var subscriptions = Set<AnyCancellable>()
		let now = Date(timeIntervalSince1970: 1616074184)
		let cellModel = CheckInTimeModel("myType", date: now, hasTopSeparator: false)

		// WHEN
		let dateChangeExpectation = expectation(description: "date did change")
		cellModel.$date.sink { update in
			XCTAssertEqual(now, update)
			dateChangeExpectation.fulfill()
		}
		.store(in: &subscriptions)

		// THEN
		XCTAssertEqual(cellModel.type, "myType")
		XCTAssertFalse(cellModel.hasTopSeparator)
		wait(for: [dateChangeExpectation], timeout: .medium)
	}

}
