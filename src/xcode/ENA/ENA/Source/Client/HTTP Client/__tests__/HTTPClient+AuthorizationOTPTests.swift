////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientAuthorizationOTPTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_AuthorizeOTP_WHEN_SuccesIsCalled_THEN_StringIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data()
		)
		let mock = HTTPClient.makeWith(mock: stack)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expirationDate: String?
		mock.authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success(let string):
				expirationDate = string
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expirationDate)

	}
}
