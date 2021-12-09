//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeBadgeWrapperTests: XCTestCase {

	func testGIVEN_homeBadgesWrapper_WHEN_updateAndReset_THEN_BothTriggerUpdateView() throws {
		// GIVEN
		let expectation = expectation(description: "Update or reset called")
		expectation.expectedFulfillmentCount = 2

		let homeBadgesWrapper = HomeBadgeWrapper()
		homeBadgesWrapper.updateView = { _ in
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.update(.unseenTests, value: nil)
		homeBadgesWrapper.reset(.riskStateIncreased)

		// THEN
		wait(for: [expectation], timeout: .short)
	}

	func testGIVEN_homeBadgesWrapperWithValues_WHEN_updateTestsUnseen_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Update called")
		expectation.expectedFulfillmentCount = 1

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 5])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.update(.unseenTests, value: 7)

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertEqual(value, "7")
	}

	func testGIVEN_homeBadgesWrapperWithValues_WHEN_updateRiskStateIncreased_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Update called")
		expectation.expectedFulfillmentCount = 1

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 5])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.update(.riskStateIncreased, value: 1)

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertEqual(value, "6")
	}

	func testGIVEN_homeBadgesWrapperWithValues_WHEN_updateBoth_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Updates called")
		expectation.expectedFulfillmentCount = 2

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 5])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.update(.riskStateIncreased, value: 1)
		homeBadgesWrapper.update(.unseenTests, value: 4)

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertEqual(value, "5")
	}


	func testGIVEN_homeBadgesWrapperWithValues_WHEN_resetRiskIncreased_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Reset called")
		expectation.expectedFulfillmentCount = 1

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 3, .riskStateIncreased: 1])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.reset(.riskStateIncreased)

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertEqual(value, "3")
	}

	func testGIVEN_homeBadgesWrapperWithValues_WHEN_resetUnseenTests_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Reset called")
		expectation.expectedFulfillmentCount = 1

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 3, .riskStateIncreased: 1])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.reset(.unseenTests)

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertEqual(value, "1")
	}

	func testGIVEN_homeBadgesWrapperWithValues_WHEN_resetAll_THEN_CountValueIsCorrect() {
		// GIVEN
		let expectation = expectation(description: "Reset all called")
		expectation.expectedFulfillmentCount = 1

		var value: String?
		let homeBadgesWrapper = HomeBadgeWrapper([.unseenTests: 3, .riskStateIncreased: 1])
		homeBadgesWrapper.updateView = { newValue in
			value = newValue
			expectation.fulfill()
		}

		// WHEN
		homeBadgesWrapper.restAll()

		// THEN
		wait(for: [expectation], timeout: .short)
		XCTAssertNil(value)
	}

}
