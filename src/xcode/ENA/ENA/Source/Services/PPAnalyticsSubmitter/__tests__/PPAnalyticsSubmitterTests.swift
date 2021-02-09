////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPAnalyticsSubmitterTests: XCTestCase {

	// MARK: - getValidOTP

	func testGIVEN_Submission_WHEN_SuccessSubmissionIsTriggered_THEN_Success() {

		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
		)

		// WHEN
		analyticsSubmitter.triggerSubmitData()

		// THEN


	}
}
