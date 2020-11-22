//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ENSettingEuTracingViewModelTests: XCTestCase {
	
	func testENSettingEuTracingViewModelTests_Init() throws {
		
		let viewModel = ENSettingEuTracingViewModel()
		XCTAssertNotNil(viewModel)
	}
	
	func testENSettingEuTracingViewModelTests_LabelsAsExpected() throws {
		
		let viewModel = ENSettingEuTracingViewModel()
		
		XCTAssertNotEqual(viewModel.title, "", "Localized (i18n) Title should not be empty)")
		XCTAssertNotEqual(viewModel.countryListLabel, "", "Sub title label should be empty.")
	}
}
