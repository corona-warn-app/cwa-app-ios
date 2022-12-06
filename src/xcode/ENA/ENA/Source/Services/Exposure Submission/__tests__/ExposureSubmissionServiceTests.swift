//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest
import HealthCertificateToolkit

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionServiceTests: CWATestCase {

	let keys = [ENTemporaryExposureKey()]
	
	// MARK: - Exposure Submission
	
	func testSubmitExposure_Success() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let store = MockTestStore()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				// Key submission result.
				.success(())
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "dummyRegistrationToken",
			finalTestResultReceivedDate: Date(timeIntervalSince1970: 12345678),
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let appConfigurationProvider = CachedAppConfigurationMock()
		
		var deadmanNotificationManager = MockDeadmanNotificationManager()
		
		let deadmanResetExpectation = expectation(description: "Deadman notification reset")
		deadmanNotificationManager.resetDeadmanNotificationCalled = {
			deadmanResetExpectation.fulfill()
		}
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			deadmanNotificationManager: deadmanNotificationManager,
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		service.symptomsOnset = .lastSevenDays
		
		let successExpectation = self.expectation(description: "Success")
		
		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertNil(error)
			
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertNil(error)
				successExpectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertNil(coronaTestService.pcrTest.value?.submissionTAN)
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == true)
		
		/// The date of the test result is still needed because it is shown on the home screen after the submission
		XCTAssertNotNil(coronaTestService.pcrTest.value?.finalTestResultReceivedDate)
		
		XCTAssertNil(store.submissionKeys)
		XCTAssertTrue(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
	}
	
	func test_When_SubmissionWasSuccessful_Then_CheckinSubmittedIsTrue() {
		let keysRetrievalMock = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let store = MockTestStore()
		
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		let restServiceProvider = RestServiceProviderStub(
			results: [
				// Key submission result.
				.success(())
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "regToken",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		store.submissionKeys = [SAP_External_Exposurenotification_TemporaryExposureKey()]
		store.submissionCheckins = [eventStore.checkinsPublisher.value[0]]
		
		let checkinSubmissionService = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keysRetrievalMock,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let completionExpectation = expectation(description: "Completion should be called.")
		checkinSubmissionService.submitExposure(coronaTestType: .pcr) { error in
			XCTAssertNil(error)
			XCTAssertTrue(eventStore.checkinsPublisher.value[0].checkinSubmitted)
			
			completionExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testSubmitExposure_NoSubmissionConsent() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let store = MockTestStore()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			isSubmissionConsentGiven: false
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "NoSubmissionConsent")
		
		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .preconditionError(.noSubmissionConsent))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertNil(coronaTestService.pcrTest.value?.registrationToken)
		XCTAssertNil(coronaTestService.pcrTest.value?.submissionTAN)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.isSubmissionConsentGiven == false)
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == false)
		
		XCTAssertEqual(store.submissionKeys, [])
		XCTAssertEqual(store.submissionCheckins, [])
		XCTAssertFalse(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
	}
	
	func testSubmitExposure_KeysNotShared() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "KeysNotShared")
		
		// Act
		service.submitExposure(coronaTestType: .pcr) { error in
			XCTAssertEqual(error, .preconditionError(.keysNotShared))
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.isSubmissionConsentGiven == true)
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == false)
	}
	
	
	func testSubmitExposure_PositiveTestResultNotShown() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))

		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			positiveTestResultWasShown: false,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "PositiveTestResultNotShown")
		
		// Act
		service.submitExposure(coronaTestType: .pcr) { error in
			XCTAssertEqual(error, .preconditionError(.positiveTestResultNotShown))
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.isSubmissionConsentGiven == true)
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == false)
	}
	
	func testSubmitExposure_KeysNotSharedDueToNotAuthorizedError() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, ENError(.notAuthorized)))
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "KeysNotShared")
		
		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertEqual(error, .notAuthorized)
			
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .preconditionError(.keysNotShared))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.isSubmissionConsentGiven == true)
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == false)
	}
	
	func testSubmitExposure_NoKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "NoKeys")
		
		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .preconditionError(.noKeysCollected))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == true)
	}
	
	func testSubmitExposure_EmptyKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil))
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "EmptyKeys")
		
		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .preconditionError(.noKeysCollected))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.keysSubmitted == true)
	}
	
	func testExposureSubmission_InvalidPayloadOrHeaders() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.failure(ServiceError<KeySubmissionResourceError>.receivedResourceError(.invalidPayloadOrHeaders))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "asdf",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "invalidPayloadOrHeaders Error")
		
		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .keySubmissionError(.receivedResourceError(.invalidPayloadOrHeaders)))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(coronaTestService.pcrTest.value?.isSubmissionConsentGiven == true)
	}
	
	func testSubmitExposure_NoRegToken() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
				.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: nil,
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		coronaTestService.getSubmissionTANResult = .failure(.noRegistrationToken)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "InvalidRegToken")
		
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .coronaTestServiceError(.noRegistrationToken))
				expectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testCorrectErrorForRequestCouldNotBeBuilt() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let restServiceProvider = RestServiceProviderStub(
			results: [
				// Key submission result.
				.failure(ServiceError<KeySubmissionResourceError>.receivedResourceError(.requestCouldNotBeBuilt))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "dummyRegistrationToken",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."
		
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				expectation.fulfill()
				XCTAssertEqual(error?.localizedDescription, controlTest)
			}
		}
		
		waitForExpectations(timeout: .short)
	}
	
	func testCorrectErrorForInvalidPayloadOrHeaders() {
		// Initialize.
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let restServiceProvider = RestServiceProviderStub(
			results: [
				// Key submission result.
				.failure(ServiceError<KeySubmissionResourceError>.receivedResourceError(.invalidPayloadOrHeaders))
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "dummyRegistrationToken",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		// Execute test.
		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."
		
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				expectation.fulfill()
				XCTAssertEqual(error?.localizedDescription, controlTest)
			}
		}
		
		waitForExpectations(timeout: .short)
	}
	
	/// The submit exposure flow consists of two steps:
	/// 1. Getting a submission tan
	/// 2. Submitting the keys
	/// In this test, we make the 2. step fail and retry the full submission. The test makes sure that we do not burn the tan when the second step fails.
	func test_partialSubmissionFailure() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))

		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				// 1. Failed key submission result.
				LoadResource(result: .failure(ServiceError<KeySubmissionResourceError>.unexpectedServerError(500)), willLoadResource: nil),
				// 2. Successful key submission result (retry).
				LoadResource(result: .success(()), willLoadResource: nil)
			]
		)
		
		let coronaTestService = MockCoronaTestService()
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "dummyRegistrationToken",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 2
		
		// Execute test.
		
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { result in
				expectation.fulfill()
				XCTAssertNotNil(result)
				
				// Retry.
				service.submitExposure(coronaTestType: .pcr) { result in
					expectation.fulfill()
					XCTAssertNil(result)
				}
			}
		}
		
		waitForExpectations(timeout: .medium)
	}
	
	// MARK: - Country Loading
	
	func testLoadSupportedCountriesLoadSucceeds() {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "IT", "ES"]
		let appConfiguration = CachedAppConfigurationMock(with: config)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: appConfiguration,
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: MockCoronaTestService(),
			ppacService: ppacService
		)
		
		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()
		
		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2
		
		let onSuccessExpectation = expectation(description: "onSuccess is called")
		
		service.loadSupportedCountries(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { supportedCountries in
				XCTAssertEqual(supportedCountries, [Country(countryCode: "DE"), Country(countryCode: "IT"), Country(countryCode: "ES")])
				onSuccessExpectation.fulfill()
			}
		)
		
		waitForExpectations(timeout: .short)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	func testLoadSupportedCountriesLoadEmpty() {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = []
		let appConfiguration = CachedAppConfigurationMock(with: config)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: appConfiguration,
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: MockCoronaTestService(),
			ppacService: ppacService
		)
		
		let expectedIsLoadingValues = [true, false]
		var isLoadingValues = [Bool]()
		
		let isLoadingExpectation = expectation(description: "isLoading is called twice")
		isLoadingExpectation.expectedFulfillmentCount = 2
		
		let onSuccessExpectation = expectation(description: "onSuccess is called")
		
		service.loadSupportedCountries(
			isLoading: {
				isLoadingValues.append($0)
				isLoadingExpectation.fulfill()
			},
			onSuccess: { supportedCountries in
				XCTAssertEqual(supportedCountries, [Country(countryCode: "DE")])
				onSuccessExpectation.fulfill()
			}
		)
		
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(isLoadingValues, expectedIsLoadingValues)
	}
	
	// MARK: - Properties
	
	func testExposureManagerState() {
		let exposureManagerState = ExposureManagerState(authorized: false, enabled: true, status: .unknown)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(
				diagnosisKeysResult: ([], nil),
				exposureManagerState: exposureManagerState
			),
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: .fake(),
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: MockCoronaTestService(),
			ppacService: ppacService
		)
		
		XCTAssertEqual(service.exposureManagerState, exposureManagerState)
	}
	
	// MARK: - Plausible Deniability
	
	func test_submitExposurePlaybook() {
		// Counter to track the execution order.
		var count = 0
		
		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4
		
		// Initialize.
		
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						expectation.fulfill()
						guard let resource = resource as? RegistrationTokenResource else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						XCTAssertTrue(resource.locator.isFake)
						XCTAssertEqual(count, 0)
						count += 1
					}
				),
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						expectation.fulfill()
						guard let resource = resource as? RegistrationTokenResource else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						XCTAssertFalse(resource.locator.isFake)
						XCTAssertEqual(count, 1)
						count += 1
					}
				),
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						expectation.fulfill()
						XCTAssertFalse(submissionResource.locator.isFake)
						XCTAssertEqual(count, 2)
						count += 1
					}
				)],
			isFakeResourceLoadingActive: true
		)

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfigurationProvider,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: restServiceProvider, store: MockTestStore())
		)
		
		let coronaTestService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfigurationProvider,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		coronaTestService.pcrTest.value = .mock(
			registrationToken: "dummyRegToken",
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)

		// Run test.
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: CachedAppConfigurationMock(),
			restServiceProvider: restServiceProvider,
			store: MockTestStore(),
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService,
			ppacService: ppacService
		)
		
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				expectation.fulfill()
				XCTAssertNil(error)
			}
		}
		
		waitForExpectations(timeout: .short)
	}
	
}
