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
		let dateString = "2021-02-16T08:34:00+00:00"
		let dateFormatter = ISO8601DateFormatter()
		let isoDate = dateFormatter.date(from: dateString)

		let dict: [String: String] = ["expirationDate": dateString]

		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = .iso8601
		let encoded = try? jsonEncoder.encode(dict)

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		let mock = HTTPClient.makeWith(mock: stack)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expirationDate: Date?
		mock.authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success(let date):
				expirationDate = date
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expirationDate)
		XCTAssertEqual(expirationDate, isoDate)

	}
}
