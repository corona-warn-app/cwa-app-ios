//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionServiceTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2
	let keys = [ENTemporaryExposureKey()]

	// MARK: - Exposure Submission

	func testSubmitExposure_Success() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "dummyRegistrationToken",
			testResultReceivedDate: Date(timeIntervalSince1970: 12345678),
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: true
		)

		let appConfigurationProvider = CachedAppConfigurationMock()

		var deadmanNotificationManager = MockDeadmanNotificationManager()

		let deadmanResetExpectation = expectation(description: "Deadman notification reset")
		deadmanNotificationManager.resetDeadmanNotificationCalled = {
			deadmanResetExpectation.fulfill()
		}

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: MockEventStore(),
			deadmanNotificationManager: deadmanNotificationManager,
			coronaTestService: coronaTestService
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

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertNil(coronaTestService.pcrTest?.registrationToken)
		XCTAssertNil(coronaTestService.pcrTest?.submissionTAN)
		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == true)

		/// The date of the test result is still needed because it is shown on the home screen after the submission
		XCTAssertNotNil(coronaTestService.pcrTest?.testResultReceivedDate)

		XCTAssertNil(store.submissionKeys)
		XCTAssertTrue(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
	}

	func testSubmitExposure_NoSubmissionConsent() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			isSubmissionConsentGiven: false
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "NoSubmissionConsent")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .noSubmissionConsent)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertNil(coronaTestService.pcrTest?.registrationToken)
		XCTAssertNil(coronaTestService.pcrTest?.submissionTAN)

		XCTAssertTrue(coronaTestService.pcrTest?.isSubmissionConsentGiven == false)
		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == false)

		XCTAssertEqual(store.submissionKeys, [])
		XCTAssertFalse(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
	}

	func testSubmitExposure_KeysNotShared() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			isSubmissionConsentGiven: true
		)

		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "KeysNotShared")

		// Act
		service.submitExposure(coronaTestType: .pcr) { error in
			XCTAssertEqual(error, .keysNotShared)
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(coronaTestService.pcrTest?.isSubmissionConsentGiven == true)
		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == false)
	}

	func testSubmitExposure_KeysNotSharedDueToNotAuthorizedError() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, ENError(.notAuthorized)))
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "KeysNotShared")

		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertEqual(error, .notAuthorized)

			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .keysNotShared)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(coronaTestService.pcrTest?.isSubmissionConsentGiven == true)
		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == false)
	}

	func testSubmitExposure_NoKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "NoKeys")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .noKeysCollected)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == true)
	}

	func testSubmitExposure_EmptyKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil))
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "EmptyKeys")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .noKeysCollected)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(coronaTestService.pcrTest?.keysSubmitted == true)
	}

	func testExposureSubmission_InvalidPayloadOrHeaders() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()
		let eventStore = MockEventStore()
		store.registrationToken = "dummyRegistrationToken"
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "asdf",
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "invalidPayloadOrHeaders Error")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .invalidPayloadOrHeaders)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(coronaTestService.pcrTest?.isSubmissionConsentGiven == true)
	}

	func testSubmitExposure_NoRegToken() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let eventStore = MockEventStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: nil,
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "InvalidRegToken")

		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { error in
				XCTAssertEqual(error, .coronaTestServiceError(.noRegistrationToken))
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testCorrectErrorForRequestCouldNotBeBuilt() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let client = ClientMock(submissionError: .requestCouldNotBeBuilt)
		let store = MockTestStore()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "dummyRegistrationToken",
			isSubmissionConsentGiven: true
		)

		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService
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
		let appConfigurationProvider = CachedAppConfigurationMock()
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "dummyRegistrationToken",
			isSubmissionConsentGiven: true
		)

		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService
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
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()

		// Force submission error. (Which should result in a 4xx, not a 5xx!)
		let client = ClientMock(submissionError: .serverError(500))
		client.onGetTANForExposureSubmit = { _, _, completion in completion(.success("dummyTan")) }

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "dummyRegistrationToken",
			isSubmissionConsentGiven: true
		)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService
		)

		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 2

		// Execute test.

		service.getTemporaryExposureKeys { _ in
			service.submitExposure(coronaTestType: .pcr) { result in
				expectation.fulfill()
				XCTAssertNotNil(result)

				// Retry.
				client.onSubmitCountries = { $2(.success(())) }
				client.onGetTANForExposureSubmit = { _, isFake, completion in
					XCTAssertTrue(isFake, "When executing the real request, instead of using the stored TAN, we have made a request to the server.")
					completion(.failure(.fakeResponse))
				}
				service.submitExposure(coronaTestType: .pcr) { result in

					expectation.fulfill()
					XCTAssertNil(result)
				}
			}
		}

		waitForExpectations(timeout: .short)
	}

	// MARK: - Country Loading

	func testLoadSupportedCountriesLoadSucceeds() {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "IT", "ES"]

		let client = ClientMock()

		let store = MockTestStore()
		let eventStore = MockEventStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: CachedAppConfigurationMock(with: config),
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: CoronaTestService(client: client, store: store)
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

		let client = ClientMock()

		let store = MockTestStore()
		let eventStore = MockEventStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: CachedAppConfigurationMock(with: config),
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: CoronaTestService(client: client, store: store)
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

		let client = ClientMock()

		let store = MockTestStore()
		let eventStore = MockEventStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(
				diagnosisKeysResult: ([], nil),
				exposureManagerState: exposureManagerState
			),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: client,
			store: store,
			eventStore: eventStore,
			coronaTestService: CoronaTestService(client: client, store: store)
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
		let client = ClientMock()

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			if isFake {
				XCTAssertEqual(count, 0)
				count += 1
				completion(.failure(.fakeResponse))
			} else {
				XCTAssertEqual(count, 1)
				count += 1
				completion(.success("dummyTan"))
			}
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertFalse(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		let coronaTestService = CoronaTestService(client: client, store: store)
		coronaTestService.pcrTest = PCRTest.mock(
			registrationToken: "dummyRegToken",
			isSubmissionConsentGiven: true
		)

		// Run test.

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: keyRetrieval,
			appConfigurationProvider: appConfigurationProvider,
			client: client, store: store,
			eventStore: MockEventStore(),
			coronaTestService: coronaTestService
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
