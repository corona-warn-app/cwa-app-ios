////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskLegendeTest: XCTestCase {

	func testGIVEN_riskLegendeViewController_WHEN_loaddynamicTableViewModel_THEN_SectionsMatch() {
		// GIVEN
		let riskLegendeViewController = RiskLegendViewController(onDismiss: {})

		// WHEN

		let view = riskLegendeViewController.view
		let dynamicTableViewModel = riskLegendeViewController.dynamicTableViewModel

		// THEN
		XCTAssertNotNil(view)
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 10)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 7)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 3), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 4), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 5), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 6), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 7), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 8), 2)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 9), 2)
	}

	func testGIVEN_riskLegendeViewController_WHEN_triggerClodeAction_THEN_OnDissMissGetsCalled() {
		// GIVEN
		let closexpectation = expectation(description: "close button hit")

		let riskLegendeViewController = RiskLegendViewController(onDismiss: {
			closexpectation.fulfill()
		})

		// WHEN
		riskLegendeViewController.onDismiss()

		// THEN

		wait(for: [closexpectation], timeout: .medium)
	}
}
