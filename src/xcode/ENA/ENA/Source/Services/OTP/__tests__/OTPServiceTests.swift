////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class OTPServiceTests: CWATestCase {

	// MARK: - getValidOTPEdus

	func testGIVEN_OTPService_WHEN_NoOtpEdusIsStored_THEN_SuccessAndOtpEdusIsGeneratedAndReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	func testGIVEN_OTPService_WHEN_ExistingButValidOtpEdusIsStored_THEN_SuccessAndStoredOtpEdusIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	func testGIVEN_OTPService_WHEN_OtpEdusIsNotAvailable_AND_AuthorizedLastMonth_THEN_NewOTPEdusIsReturned() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	func testGIVEN_OTPService_WHEN_OtpEdusIsNotAvailable_AND_AuthorizedThisMonth_THEN_ErrorIsReturned() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	// MARK: - discardOTPEdus

	func testGIVEN_StoredOtp_WHEN_RiskChangesToLow_THEN_OtpEdusIsDiscarded() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)

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

	func testGIVEN_StoredOtp_WHEN_OtpEdusIsDiscarded_THEN_OtpEdusIsNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	func testGIVEN_NoStoredOtp_WHEN_OtpEdusIsDiscarded_THEN_OtpEdusIsStillNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		XCTAssertNil(store.otpTokenEdus)

		// WHEN
		otpService.discardOTPEdus()

		// THEN
		XCTAssertNil(store.otpTokenEdus)
	}

	// MARK: - isOTPEdusAvailable

	func testGIVEN_StoredAndAuthorizedOTPEdus_WHEN_isOTPEdusAvailable_THEN_TrueIsReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
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

	func testGIVEN_StoredButNotAuthorizedOTPEdus_WHEN_isStoredOTPEdusAuthorized_THEN_FalseIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		
		// WHEN
		let isAuthorized = otpService.isOTPEdusAvailable

		// THEN
		XCTAssertFalse(isAuthorized)
	}
	
	// MARK: - getValidOTPEdus
	
	func testGIVEN_OTPService_WHEN_NoOtpElsIsStored_THEN_SuccessAndOtpElsIsGeneratedAndReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEls)
		XCTAssertEqual(expectedOtp, store.otpTokenEls?.token)
	}
	
	func testGIVEN_OTPService_WHEN_ExistingOTPElsExpirationDateIsNil_THEN_SuccessAndNewOtpElsIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: nil)
		store.otpTokenEls = oldToken
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
			case .failure:
				XCTFail("Test should not fail")
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertEqual(responseOtp, store.otpTokenEls?.token)
		XCTAssertNotEqual(responseOtp, oldToken.token)
		XCTAssertNotEqual(oldToken.token, store.otpTokenEls?.token)
	}

	func testGIVEN_OTPService_WHEN_ExistingOTPElsNotExceededAndNotAuthorized_THEN_SuccessAndOldOtpElsIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let dateInFuture = Calendar.current.date(byAdding: .day, value: 10, to: Date())
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: dateInFuture)
		store.otpTokenEls = oldToken
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
			case .failure:
				XCTFail("Test should not fail")
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertEqual(responseOtp, store.otpTokenEls?.token)
		XCTAssertEqual(responseOtp, oldToken.token)
		XCTAssertEqual(oldToken.token, store.otpTokenEls?.token)
	}
	
	func testGIVEN_OTPService_WHEN_ExistingOTPElsExceededAndNotAuthorized_THEN_SuccessAndNewOtpElsIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let dateInPast = Calendar.current.date(byAdding: .day, value: -10, to: Date())
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: dateInPast)
		store.otpTokenEls = oldToken
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
			case .failure:
				XCTFail("Test should not fail")
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertEqual(responseOtp, store.otpTokenEls?.token)
		XCTAssertNotEqual(responseOtp, oldToken.token)
		XCTAssertNotEqual(oldToken.token, store.otpTokenEls?.token)
	}
	
	func testGIVEN_OTPService_WHEN_ExistingOTPElsNotExceededAndAuthorized_THEN_SuccessAndNewOtpElsIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let dateInFuture = Calendar.current.date(byAdding: .day, value: 10, to: Date())
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: dateInFuture)
		store.otpTokenEls = oldToken
		store.otpElsAuthorizationDate = Date()
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
			case .failure:
				XCTFail("Test should not fail")
			}
			expectation.fulfill()
		})

		// THEN
		waitForExpectations(timeout: .short)

		let responseOtp = try XCTUnwrap(expectedOtp)
		XCTAssertEqual(responseOtp, store.otpTokenEls?.token)
		XCTAssertNotEqual(responseOtp, oldToken.token)
		XCTAssertNotEqual(oldToken.token, store.otpTokenEls?.token)
	}
	func testGIVEN_OTPService_WHEN_ExistingOTPElsExceededAndAuthorized_THEN_SuccessAndNewOtpElsIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		let dateInPast = Calendar.current.date(byAdding: .day, value: -10, to: Date())
		let oldToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: dateInPast)
		store.otpTokenEls = oldToken
		store.otpElsAuthorizationDate = Date()
		var expectedOtp: String?

		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEls)
		XCTAssertEqual(responseOtp, store.otpTokenEls?.token)
		XCTAssertNotEqual(responseOtp, oldToken.token)
		XCTAssertNotEqual(oldToken.token, store.otpTokenEls?.token)
	}

	func testGIVEN_OTPService_WHEN_AuthorizedThisMonth_THEN_SameOTPElsIsReturned() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")

		let existingToken = OTPToken(token: "otpTokenFake", timestamp: Date(), expirationDate: nil)
		store.otpTokenEls = existingToken
		
		let currentMonth = Calendar.current.component(.month, from: Date())
		let currentMonthDate = Calendar.current.date(from: DateComponents(calendar: Calendar.current, month: currentMonth))
		store.otpElsAuthorizationDate = currentMonthDate
		
		var expectedOtp: String?
		
		// WHEN
		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success(let otp):
				expectedOtp = otp
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		waitForExpectations(timeout: .short)
		XCTAssertEqual(store.otpTokenEls?.token, expectedOtp)
	}
	
	// MARK: - discardOTPEls
	
	func testGIVEN_StoredOtp_WHEN_OtpElsIsDiscarded_THEN_OtpElsIsNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let loadResource = LoadResource(
			result: .success(
				OTPResponsePropertiesReceiveModel(
					expirationDate: Date(),
					errorCode: nil)
			),
			willLoadResource: nil
		)
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(loadResources: [loadResource]),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		let ppacToken = PPACToken(apiToken: "apiTokenFake", deviceToken: "deviceTokenFake")

		let expectation = self.expectation(description: "completion handler is called without an error")
		var expectedOtp: String?

		otpService.getOTPEls(ppacToken: ppacToken, completion: { result in
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
		XCTAssertNotNil(store.otpTokenEls)
		XCTAssertEqual(expectedOtp, store.otpTokenEls?.token)

		// WHEN
		otpService.discardOTPEls()

		// THEN
		XCTAssertNil(store.otpTokenEls)
	}

	func testGIVEN_NoStoredOtp_WHEN_OtpElsIsDiscarded_THEN_OtpElsIsStillNil() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			restServiceProvider: RestServiceProviderStub(),
			riskProvider: riskProvider,
			ppacService: ppacService,
			appConfiguration: CachedAppConfigurationMock()
		)
		XCTAssertNil(store.otpTokenEls)

		// WHEN
		otpService.discardOTPEls()

		// THEN
		XCTAssertNil(store.otpTokenEls)
	}
}
