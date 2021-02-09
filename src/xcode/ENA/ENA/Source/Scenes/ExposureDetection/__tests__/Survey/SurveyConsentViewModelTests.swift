////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SurveyConsentViewModelTests: XCTestCase {

	func test_WHEN_dynamicTableViewModel_THEN_CorrectModelIsReturned() throws {
		let viewModel = SurveyConsentViewModel(
			surveyURLProvider: SurveyURLProviderFake()
		)

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 4)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 1)
	}
}

private struct SurveyURLProviderFake: SurveyURLProvidable {
	func getURL(_ completion: @escaping (Result<URL, SurveyError>) -> Void) { }
}
