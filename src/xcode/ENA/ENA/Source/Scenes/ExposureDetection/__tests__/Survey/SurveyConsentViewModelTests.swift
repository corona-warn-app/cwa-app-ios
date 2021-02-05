////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SurveyConsentViewModelTests: XCTestCase {

	func testDynamicTableViewModel() throws {
		let store = MockTestStore()
		let client =  ClientMock()
		let otpService = OTPService(store: store, client: client)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)

		let viewModel = SurveyConsentViewModel(
			configurationProvider: CachedAppConfigurationMock(),
			ppacService: ppacService,
			otpService:	otpService
		)

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 4)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 1)
	}
}
