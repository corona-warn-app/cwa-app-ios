////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientAuthorizationOTPTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_AuthorizeOTP_WHEN_SuccesWithAuthorization_THEN_ExpirationDateIsReturned() throws {
		// GIVEN
		let dateString = "2021-02-16T08:34:00+00:00"
		let dateFormatter = ISO8601DateFormatter()
		let isoDate = dateFormatter.date(from: dateString)

		let response: [String: String] = ["expirationDate": dateString]

		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = .iso8601
		let encoded = try jsonEncoder.encode(response)

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expirationDate: Date?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
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

	func testGIVEN_AuthorizeOTP_WHEN_Success_JsonParsing_THEN_invalidResponseErrorIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .invalidResponseError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_API_TOKEN_ALREADY_ISSUEDIsCalled_THEN_apiTokenAlreadyIssuedIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_ALREADY_ISSUED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .apiTokenAlreadyIssued)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_API_TOKEN_EXPIREDIsCalled_THEN_apiTokenExpiredIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_EXPIRED"]
		let stack = MockNetworkStack(
			httpStatus: 401,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .apiTokenExpired)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_API_TOKEN_QUOTA_EXCEEDEDIsCalled_THEN_apiTokenQuotaExceededIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "API_TOKEN_QUOTA_EXCEEDED"]
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .apiTokenQuotaExceeded)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_DEVICE_TOKEN_INVALIDIsCalled_THEN_deviceTokenInvalidIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "DEVICE_TOKEN_INVALID"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .deviceTokenInvalid)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_DEVICE_TOKEN_REDEEMEDIsCalled_THEN_deviceTokenRedeemedIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "DEVICE_TOKEN_REDEEMED"]
		let stack = MockNetworkStack(
			httpStatus: 401,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .deviceTokenRedeemed)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_DEVICE_TOKEN_SYNTAX_ERRORIsCalled_THEN_deviceTokenSyntaxErrorIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "DEVICE_TOKEN_SYNTAX_ERROR"]
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .deviceTokenSyntaxError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_OtherServerErrorIsCalled_THEN_otherServerErrorIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["errorCode": "JWS_SIGNATURE_VERIFICATION_FAILED"]
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .otherServerError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_JSONSyntaxError_THEN_invalidResponseErrorIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["jsonError": "JWS_SIGNATURE_VERIFICATION_FAILED"]
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .invalidResponseError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_500StatusCode_THEN_internalServerErrorIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["jsonError": "JWS_SIGNATURE_VERIFICATION_FAILED"]
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .internalServerError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_UnkownStatusCode_THEN_internalServerErrorIsReturned() throws {
		// GIVEN
		let response: [String: String] = ["jsonError": "JWS_SIGNATURE_VERIFICATION_FAILED"]
		let stack = MockNetworkStack(
			httpStatus: 91,
			responseData: try JSONEncoder().encode(response)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .internalServerError)
	}

	func testGIVEN_AuthorizeOTP_WHEN_Failure_JsonParsing_THEN_invalidResponseErrorIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")
		let otp = "OTPFake"
		let ppacToken = PPACToken(apiToken: "APITokenFake", deviceToken: "DeviceTokenFake")

		// WHEN
		var expectedOtpError: OTPError?
		HTTPClient.makeWith(mock: stack).authorize(otp: otp, ppacToken: ppacToken, isFake: false, completion: { result in
			switch result {
			case .success:
				XCTFail("success should not be called")
			case .failure(let otpError):
				expectedOtpError = otpError
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(expectedOtpError)
		XCTAssertEqual(expectedOtpError, .invalidResponseError)
	}
}
