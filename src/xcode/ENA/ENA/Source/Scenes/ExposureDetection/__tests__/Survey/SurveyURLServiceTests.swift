////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SurveyURLServiceTests: CWATestCase {

	func test_WHEN_getURLIsCalled_THEN_aURLIsReturned() {
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: MockRiskProvider()
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)

		let surveyURLService = SurveyURLProvider(
			configurationProvider: CachedAppConfigurationMock(),
			ppacService: ppacService,
			otpService: otpService
		)

		let urlExpectation = expectation(description: "URL is returned.")
		surveyURLService.getURL { result in
			switch result {
			case .success:
				urlExpectation.fulfill()
			case .failure:
				XCTFail("Error not expected.")
			}
		}

		waitForExpectations(timeout: .long)
	}
}
