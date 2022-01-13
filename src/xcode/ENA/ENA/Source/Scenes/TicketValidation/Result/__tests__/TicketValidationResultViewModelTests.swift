//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TicketValidationResultViewModelTests: XCTestCase {

	func testGIVEN_ValidationResults_WHEN_PassedModelIsCreated_THEN_ModelIsSetupCorrectly() throws {
		let model = TicketValidationPassedViewModel(
			validationDate: Date(),
			serviceProvider: "serviceProvider"
		)

		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 5)
	}
	
	func testGIVEN_ValidationResults_WHEN_OpenModelIsCreated_THEN_ModelIsSetupCorrectly() throws {
		let model = TicketValidationOpenViewModel(
			validationDate: Date(),
			serviceProvider: "serviceProvider",
			validationResultItems: [
				.fake(identifier: "identifier1"),
				.fake(identifier: "identifier2")
			]
		)
		
		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		// 7 rows = 2 rows for 2 result items, 5 for the other texts, images etc.
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 7)
	}
	
	func testGIVEN_ValidationResults_WHEN_FailedModelIsCreated_THEN_ModelIsSetupCorrectly() throws {
		let model = TicketValidationFailedViewModel(
			validationDate: Date(),
			serviceProvider: "serviceProvider",
			validationResultItems: [
				.fake(identifier: "identifier1"),
				.fake(identifier: "identifier2")
			]
		)

		XCTAssertEqual(model.dynamicTableViewModel.numberOfSection, 1)
		// 7 rows = 2 rows for 2 result items, 5 for the other texts, images etc.
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 7)
	}
}
