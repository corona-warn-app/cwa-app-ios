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
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEdus)
		XCTAssertEqual(expectedOtp, store.otpTokenEdus?.token)
	}

	func testGIVEN_OTPService_WHEN_OldButValidOtpIsStored_THEN_SuccessAndStoredOtpIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: Date())
		store.otpTokenEdus = oldToken
		var expectedOtp: String?

		XCTAssertTrue(otpService.isOTPEdusAvailable)

		// WHEN
		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEdus)
		XCTAssertEqual(responseOtp, store.otpTokenEdus?.token)
		XCTAssertEqual(responseOtp, oldToken.token)
		XCTAssertEqual(oldToken.token, store.otpTokenEdus?.token)
	}

	func testGIVEN_OTPService_WHEN_OtpIsNotAvailable_AND_AuthorizedLastMonth_THEN_NewOTPIsReturned() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")

		let currentMonth = Calendar.current.component(.month, from: Date())
		let lastMonthDate = Calendar.current.date(from: DateComponents(calendar: Calendar.current, month: currentMonth - 1))
		store.otpEdusAuthorizationDate = lastMonthDate

		// WHEN
		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		waitForExpectations(timeout: .short)
		XCTAssertNotNil(store.otpTokenEdus)
	}

	func testGIVEN_OTPService_WHEN_OtpIsNotAvailable_AND_AuthorizedThisMonth_THEN_ErrorIsReturned() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called with an error")
		store.otpEdusAuthorizationDate = Date()

		// WHEN
		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				XCTFail("getOTP should not succeed.")
			case .failure(let error):
				XCTAssertEqual(error, .otpAlreadyUsedThisMonth)
				expectation.fulfill()
			}
		})

		waitForExpectations(timeout: .short)
		XCTAssertNil(store.otpTokenEdus)
	}

	// MARK: - discardOTP

	func testGIVEN_StoredOtp_WHEN_RiskChangesToLow_THEN_OtpIsDiscarded() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)

		let otpToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: nil)
		store.otpTokenEdus = otpToken

		riskProvider.result = .success(Risk.mocked(level: .low))

		let riskExpectation = expectation(description: "didCalculateRisk was called.")
		let consumer = RiskConsumer()
		consumer.didCalculateRisk = { _ in
			riskExpectation.fulfill()
		}
		riskProvider.observeRisk(consumer)

		riskProvider.requestRisk(userInitiated: true, timeoutInterval: 1.0)

		waitForExpectations(timeout: 1.0)
		XCTAssertNil(store.otpTokenEdus)
		XCTAssertFalse(otpService.isOTPEdusAvailable)
	}

	func testGIVEN_StoredOtp_WHEN_OtpIsDiscarded_THEN_OtpIsNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEdus)
		XCTAssertEqual(expectedOtp, store.otpTokenEdus?.token)

		// WHEN
		otpService.discardOTPEdus()

		// THEN
		XCTAssertNil(store.otpTokenEdus)
	}

	func testGIVEN_NoStoredOtp_WHEN_OtpIsDiscarded_THEN_OtpIsStillNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		XCTAssertNil(store.otpTokenEdus)

		// WHEN
		otpService.discardOTPEdus()

		// THEN
		XCTAssertNil(store.otpTokenEdus)
	}

	// MARK: - isOTPAvailable

	func testGIVEN_StoredAndAuthorizedOTP_WHEN_isOTPAvailable_THEN_TrueIsReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?


		otpService.getOTPEdus(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEdus)
		XCTAssertEqual(expectedOtp, store.otpTokenEdus?.token)

		// WHEN, THEN
		XCTAssertTrue(otpService.isOTPEdusAvailable)
	}

	func testGIVEN_StoredButNotAuthorizedOTP_WHEN_isStoredOTPAuthorized_THEN_FalseIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(store: store, client: client, riskProvider: riskProvider)
		
		// WHEN
		let isAuthorized = otpService.isOTPEdusAvailable

		// THEN
		XCTAssertFalse(isAuthorized)
	}
}
