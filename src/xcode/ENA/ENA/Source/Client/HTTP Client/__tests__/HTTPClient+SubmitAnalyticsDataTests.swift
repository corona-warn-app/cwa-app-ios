////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientSubmitAnalyticsDataTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_SubmitAnalyticsData_WHEN_Success_THEN_CompletionIsEmpty() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let payload = SAP_Internal_Ppdd_PPADataIOS.with {
			$0.exposureRiskMetadataSet = []
		}
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var isSuccess = false
		HTTPClient.makeWith(mock: stack).submit(
			payload: payload,
			ppacToken: ppacToken,
			isFake: false,
			completion: { result in
				switch result {
			 case .success:
				isSuccess = true
			 case .failure(let error):
				 XCTFail(error.localizedDescription)
			 }
			 expectation.fulfill()
			}
		)

		// THEN
		XCTAssertEqual(isSuccess, true)
	}
}
