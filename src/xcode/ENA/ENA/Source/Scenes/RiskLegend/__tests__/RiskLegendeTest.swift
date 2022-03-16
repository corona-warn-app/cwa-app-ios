////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class RiskLegendeTest: CWATestCase {

	func testGIVEN_riskLegendeViewController_WHEN_loaddynamicTableViewModel_THEN_SectionsMatch() {
		var subscriptions = Set<AnyCancellable>()
		let appConfigProvider = CachedAppConfigurationMock()
		
		// GIVEN
		let riskLegendeViewController = RiskLegendViewController(
			onDismiss: {},
			appConfigProvider: appConfigProvider
		)

		// WHEN
		
		// Trigger 'viewDidLoad'
		let view = riskLegendeViewController.view

		// Wait until the app config loads.
		// dynamicTableViewModel will be created after app config is loaded.
		let appConfigurationExpectation = expectation(description: "appConfigurationIsSet")
		appConfigProvider.appConfiguration()
			.sink { _ in
				appConfigurationExpectation.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
		
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

		let riskLegendeViewController = RiskLegendViewController(
			onDismiss: {
				closexpectation.fulfill()
			},
			appConfigProvider: CachedAppConfigurationMock()
		)

		// WHEN
		riskLegendeViewController.onDismiss()

		// THEN

		wait(for: [closexpectation], timeout: .medium)
	}
	
	func test_createDotCell() {
		let cell = RiskLegendDotBodyCell()
		XCTAssertNotNil(cell)
		XCTAssertEqual(cell.dotView.backgroundColor, .enaColor(for: .riskHigh))
		XCTAssertNil(cell.label.text)
	}
}
