////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OTPServiceTests: XCTestCase {

	// MARK: - getValidOTP

	func testGIVEN_OTPService_WHEN_NoOtpIsStored_THEN_SuccessAndOtpIsGeneratedAndReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		// WHEN
		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)

		XCTAssertNotNil(expectedOtp)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(expectedOtp, store.otpToken?.token)
	}

	func testGIVEN_OTPService_WHEN_OutdatedOtpIsStored_THEN_SuccessAndOtpIsGeneratedAndReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")

		let dateFormatter = ISO8601DateFormatter()
		guard let isoDate = dateFormatter.date(from: "2011-11-11T11:11:11+11:11") else {
			XCTFail("Could not create iso8601 date")
			return
		}
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: isoDate)
		store.otpToken = oldToken
		var expectedOtp: String?

		// WHEN
		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(responseOtp, store.otpToken?.token)
		XCTAssertNotNil(oldToken, responseOtp)
	}

	func testGIVEN_OTPService_WHEN_OldButValidOtpIsStored_THEN_SuccessAndStoredOtpIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")

		let dateFormatter = ISO8601DateFormatter()
		guard let isoDate = dateFormatter.date(from: "2099-02-22T11:11:11+11:11") else {
			XCTFail("Could not create iso8601 date")
			return
		}
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: isoDate)
		store.otpToken = oldToken
		var expectedOtp: String?

		// WHEN
		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(responseOtp, store.otpToken?.token)
		XCTAssertEqual(responseOtp, oldToken.token)
		XCTAssertEqual(oldToken.token, store.otpToken?.token)
	}

	func testGIVEN_OTPService_WHEN_OldInvalidOtpIsStored_THEN_FailureIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")

		let dateFormatter = ISO8601DateFormatter()

		guard let today = Calendar.current.date(byAdding: .minute, value: 1, to: Date()),
			  let isoDate = dateFormatter.date(from: dateFormatter.string(from: today)) else {
			XCTFail("Could not create iso8601 date")
			return
		}
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: isoDate)
		store.otpToken = oldToken
		var expectedError: OTPError?

		// WHEN
		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case .failure(let otpError):
				expectedError = otpError
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseError = try XCTUnwrap(expectedError)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(responseError, .otpAlreadyUsedThisMonth)
	}

	// MARK: - discardOTP

	func testGIVEN_StoredOtp_WHEN_OtpIsDiscarded_THEN_OtpIsNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedOtp)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(expectedOtp, store.otpToken?.token)

		// WHEN
		otpService.discardOTP()

		// THEN
		XCTAssertNil(store.otpToken)
	}

	func testGIVEN_NoStoredOtp_WHEN_OtpIsDiscarded_THEN_OtpIsStillNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		XCTAssertNil(store.otpToken)

		// WHEN
		otpService.discardOTP()

		// THEN
		XCTAssertNil(store.otpToken)
	}

	// MARK: - isStoredOTPAuthorized

	func testGIVEN_StoredAndAuthorizedOTP_WHEN_isStoredOTPAuthorized_THEN_TrueIsReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?


		otpService.getValidOTP(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedOtp)
		XCTAssertNotNil(store.otpToken)
		XCTAssertEqual(expectedOtp, store.otpToken?.token)

		// WHEN
		let isAuthorized = otpService.isStoredOTPAuthorized

		// THEN
		XCTAssertTrue(isAuthorized)
	}

	func testGIVEN_NoStoredOTP_WHEN_isStoredOTPAuthorized_THEN_FalseIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)

		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: nil)
		store.otpToken = oldToken

		// WHEN
		let isAuthorized = otpService.isStoredOTPAuthorized

		// THEN
		XCTAssertFalse(isAuthorized)
	}

	func testGIVEN_StoredButNotAuthorizedOTP_WHEN_isStoredOTPAuthorized_THEN_FalseIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let otpService = OTPService(store: store, client: client)

		// WHEN
		let isAuthorized = otpService.isStoredOTPAuthorized

		// THEN
		XCTAssertFalse(isAuthorized)
	}
}
