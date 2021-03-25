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
	
	func testIsSubmissionConsentGiven_correctValueExchangeBetweenServiceAndStore() {
		let store = MockTestStore()
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		
		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		
		XCTAssertFalse(service.isSubmissionConsentGiven, "Expected value is 'false'")
		
		service.isSubmissionConsentGiven = true
		XCTAssertTrue(store.isSubmissionConsentGiven, "Expected store value is 'true'")
	}
	
	func testReset_shouldResetValues() {
		let store = MockTestStore()
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		
		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		
		service.isSubmissionConsentGiven = true
		service.reset()
		XCTAssertFalse(store.isSubmissionConsentGiven, "Expected store value is 'false'")
	}

	func testSubmitExposure_Success() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		store.positiveTestResultWasShown = true
		store.testResultReceivedTimeStamp = 12345678

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
			warnOthersReminder: WarnOthersReminder(store: store),
			deadmanNotificationManager: deadmanNotificationManager
		)
		service.isSubmissionConsentGiven = true
		service.symptomsOnset = .lastSevenDays

		let successExpectation = self.expectation(description: "Success")

		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertNil(error)

			service.submitExposure { error in
				XCTAssertNil(error)
				successExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertNil(store.registrationToken)
		XCTAssertNil(store.tan)

		/// The date of the test result is still needed because it is shown on the home screen after the submission
		XCTAssertNotNil(store.testResultReceivedTimeStamp)

		XCTAssertFalse(service.isSubmissionConsentGiven)
		XCTAssertNil(store.submissionKeys)
		XCTAssertTrue(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
		XCTAssertFalse(store.positiveTestResultWasShown)

		XCTAssertNotNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testSubmitExposure_NoSubmissionConsent() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = false

		let expectation = self.expectation(description: "NoSubmissionConsent")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				XCTAssertEqual(error, .noSubmissionConsent)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertNil(store.registrationToken)
		XCTAssertNil(store.tan)

		XCTAssertFalse(service.isSubmissionConsentGiven)
		XCTAssertEqual(store.submissionKeys, [])
		XCTAssertFalse(store.submissionCountries.isEmpty)
		XCTAssertEqual(store.submissionSymptomsOnset, .noInformation)
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testSubmitExposure_KeysNotShared() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "KeysNotShared")

		// Act
		service.submitExposure { error in
			XCTAssertEqual(error, .keysNotShared)
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(service.isSubmissionConsentGiven)
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testSubmitExposure_KeysNotSharedDueToNotAuthorizedError() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, ENError(.notAuthorized)))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "KeysNotShared")

		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertEqual(error, .notAuthorized)

			service.submitExposure { error in
				XCTAssertEqual(error, .keysNotShared)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(service.isSubmissionConsentGiven)
		XCTAssertNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testSubmitExposure_NoKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "NoKeys")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				XCTAssertEqual(error, .noKeysCollected)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertFalse(service.isSubmissionConsentGiven)
		XCTAssertNotNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testSubmitExposure_EmptyKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "EmptyKeys")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				XCTAssertEqual(error, .noKeysCollected)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
		XCTAssertNotNil(store.lastSuccessfulSubmitDiagnosisKeyTimestamp)
	}

	func testExposureSubmission_InvalidPayloadOrHeaders() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "invalidPayloadOrHeaders Error")

		// Act
		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				XCTAssertEqual(error, .invalidPayloadOrHeaders)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)

		XCTAssertTrue(service.isSubmissionConsentGiven)
	}

	func testSubmitExposure_NoRegToken() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "InvalidRegToken")

		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				XCTAssertEqual(error, .noRegistrationToken)
				expectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmitExposure_hoursSinceRegistration_hoursSinceResult() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		store.registrationToken = "dummyRegistrationToken"
		store.positiveTestResultWasShown = true
		store.testResultReceivedTimeStamp = 12345678

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
			warnOthersReminder: WarnOthersReminder(store: store),
			deadmanNotificationManager: deadmanNotificationManager
		)
		service.updateStoreWithKeySubmissionMetadataDefaultValues()
		service.isSubmissionConsentGiven = true
		service.symptomsOnset = .lastSevenDays

		let successExpectation = self.expectation(description: "Success")

		// Act
		service.getTemporaryExposureKeys { error in
			XCTAssertNil(error)

			service.submitExposure { error in
				XCTAssertNil(error)
				successExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
		
		
		XCTAssertNotNil(store.keySubmissionMetadata?.hoursSinceTestResult)
		XCTAssertNotNil(store.keySubmissionMetadata?.hoursSinceTestRegistration)
		XCTAssertTrue(((store.keySubmissionMetadata?.submitted) != false))
	}

	func testCorrectErrorForRequestCouldNotBeBuilt() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let client = ClientMock(submissionError: .requestCouldNotBeBuilt)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."

		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
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
		store.registrationToken = "dummyRegistrationToken"
		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		// Execute test.
		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."

		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
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
		let tan = "dummyTan"
		let registrationToken = "dummyRegistrationToken"

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.registrationToken = registrationToken

		// Force submission error. (Which should result in a 4xx, not a 5xx!)
		let client = ClientMock(submissionError: .serverError(500))
		client.onGetTANForExposureSubmit = { _, _, completion in completion(.success(tan)) }

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 2

		// Execute test.

		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				expectation.fulfill()
				XCTAssertNotNil(error)

				// Retry.
				client.onSubmitCountries = { $2(.success(())) }
				client.onGetTANForExposureSubmit = { _, isFake, completion in
					XCTAssertTrue(isFake, "When executing the real request, instead of using the stored TAN, we have made a request to the server.")
					completion(.failure(.fakeResponse))
				}
				service.submitExposure { error in
					expectation.fulfill()
					XCTAssertNil(error)
				}
			}
		}

		waitForExpectations(timeout: .short)
	}

	// MARK: - Test Result

	func testGetTestResult_success() {

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		let expectation = self.expectation(description: "Expect to receive a result.")

		// Execute test.

		service.getTestResult { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_noRegistrationToken() {

		// Initialize.
		let expectation = self.expectation(description: "Expect to receive a result.")

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		// Execute test.

		service.getTestResult { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_fetchRegistrationToken() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to receive a result.")

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let testResult):
				XCTAssertEqual(testResult, .positive)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_TestRetrievalsucceed_TestMetadataCreated() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to receive a result.")
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)
		store.riskCalculationResult = mockRiskCalculationResult()
		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				XCTAssertNotNil(store.testResultMetadata?.testResult)
				XCTAssertNotNil(store.testResultMetadata?.testRegistrationDate)
			}
		}

		waitForExpectations(timeout: .short)
	}
	
	func testGetTestResult_TestRetrievalFail_TestMetadataCleared() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to receive a result.")
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.noNetworkConnection))
		}

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: client,
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)
		store.riskCalculationResult = mockRiskCalculationResult()
		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTAssertNil(store.testResultMetadata?.testResult)
				XCTAssertNotNil(store.testResultMetadata?.testRegistrationDate)
			case .success:
				XCTFail("Test is expected to fail because of no network")
			}
		}

		waitForExpectations(timeout: .short)
	}
	
	func testGetTestResult_registrationFail_TestMetadataIsNill() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to receive a result.")
		let store = MockTestStore()
		let client = ClientMock()
		client.onGetRegistrationToken = { _, _, _, completion in
			completion(.failure(ClientMock.Failure.qrAlreadyUsed))
		}

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: client,
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)
		store.riskCalculationResult = mockRiskCalculationResult()
		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTAssertNil(store.testResultMetadata)
			case .success:
				XCTFail("Test is expected to fail because of qrAlreadyUsed")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func mockRiskCalculationResult() -> RiskCalculationResult {
		RiskCalculationResult(
			riskLevel: .high,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: Date(),
			mostRecentDateWithHighRisk: Date(),
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 2,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
	}
	
	func testGetTestResult_testRegistrationDate_testResultTimeStamp() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to receive the test registration date and test result time stamp.")
		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)
		store.riskCalculationResult = mockRiskCalculationResult()
		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				XCTAssertNotNil(store.testRegistrationDate)
				XCTAssertNotNil(store.testResultReceivedTimeStamp)
			}
		}

		waitForExpectations(timeout: .short)
	}
	
	func testGetTestResult_checkHoursAndDays() throws {
		// Initialize.
		let expectation = self.expectation(description: "Expect to have daysSinceMostRecentDateAtRiskLevelAtTestRegistration and hoursSinceHighRiskWarningAtTestRegistration in the store.")
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)
		store.riskCalculationResult = mockRiskCalculationResult()
		store.dateOfConversionToHighRisk = Calendar.current.date(byAdding: .day, value: -1, to: Date())
		service.updateStoreWithKeySubmissionMetadataDefaultValues()
		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				XCTAssertNotNil(store.keySubmissionMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration)
				XCTAssertNotNil(store.keySubmissionMetadata?.hoursSinceHighRiskWarningAtTestRegistration)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_expiredTestResultValue() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let client = ClientMock()
		client.onGetTestResult = { _, _, completeWith in
			let expiredTestResultValue = 4
			completeWith(.success(expiredTestResultValue))
		}

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		let expectation = self.expectation(description: "Expect to receive a result.")
		let expectationToFailWithExpired = self.expectation(description: "Expect to fail with error of type .qrExpired")

		// Execute test.

		service.getTestResult { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				if case ExposureSubmissionError.qrExpired = error {
					expectationToFailWithExpired.fulfill()
				}
			case .success:
				XCTFail("This test should intentionally produce an expired test result that cannot be parsed.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_unknownTestResultValue() {

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let client = ClientMock()
		client.onGetTestResult = { _, _, completeWith in
			let unknownTestResultValue = 5
			completeWith(.success(unknownTestResultValue))
		}

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		let expectation = self.expectation(description: "Expect to receive a result.")
		let expectationToFailWithOther = self.expectation(description: "Expect to fail with error of type .other(_)")

		// Execute test.

		service.getTestResult { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				if case ExposureSubmissionError.other(_) = error {
					expectationToFailWithOther.fulfill()
				}
			case .success:
				XCTFail("This test should intentionally produce an unknown test result that cannot be parsed.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testDeleteTest() throws {
		let client = ClientMock()
		let registrationToken = "dummyRegistrationToken"

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.registrationToken = registrationToken
		store.isSubmissionConsentGiven = true

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))

		XCTAssertTrue(service.hasRegistrationToken)
		XCTAssertTrue(service.isSubmissionConsentGiven)

		/// Check that isSubmissionConsentGiven publisher is updated
		let expectedValues = [true, false]
		var receivedValues = [Bool]()

		let publisherExpectation = expectation(description: "isSubmissionConsentGivenPublisher published")
		publisherExpectation.expectedFulfillmentCount = 2

		let subscription = service.isSubmissionConsentGivenPublisher
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		service.deleteTest()

		XCTAssertFalse(service.hasRegistrationToken)
		XCTAssertFalse(service.isSubmissionConsentGiven)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	// MARK: - Country Loading

	func testLoadSupportedCountriesLoadSucceeds() {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "IT", "ES"]

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: CachedAppConfigurationMock(with: config),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
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

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: ([], nil)),
			appConfigurationProvider: CachedAppConfigurationMock(with: config),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
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

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(
				diagnosisKeysResult: ([], nil),
				exposureManagerState: exposureManagerState
			),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		XCTAssertEqual(service.exposureManagerState, exposureManagerState)
	}

	func testAcceptPairing() {
		let exposureManagerState = ExposureManagerState(authorized: false, enabled: true, status: .unknown)

		let store = MockTestStore()
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: MockDiagnosisKeysRetrieval(
				diagnosisKeysResult: ([], nil),
				exposureManagerState: exposureManagerState
			),
			appConfigurationProvider: CachedAppConfigurationMock(),
			client: ClientMock(),
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		XCTAssertFalse(store.devicePairingConsentAccept)
		XCTAssertNil(store.devicePairingConsentAcceptTimestamp)
		XCTAssertNil(service.devicePairingConsentAcceptTimestamp)

		service.acceptPairing()

		XCTAssertTrue(store.devicePairingConsentAccept)
		XCTAssertNotNil(store.devicePairingConsentAcceptTimestamp)
		XCTAssertNotNil(service.devicePairingConsentAcceptTimestamp)
	}

	// MARK: - Plausible Deniability

	func test_getTestResultPlaybookPositive() {
		getTestResultPlaybookTest(with: .positive)
	}

	func test_getTestResultPlaybookNegative() {
		getTestResultPlaybookTest(with: .negative)
	}

	func test_getTestResultPlaybookPending() {
		getTestResultPlaybookTest(with: .pending)
	}

	func test_getTestResultPlaybookInvalid() {
		getTestResultPlaybookTest(with: .invalid)
	}

	func test_getTestResultPlaybookExpired() {
		getTestResultPlaybookTest(with: .expired)
	}

	func test_getRegistrationTokenPlaybook() {

		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		let client = ClientMock()

		let registrationToken = "dummyRegToken"

		client.onGetRegistrationToken = { _, _, isFake, completion in
			expectation.fulfill()
			XCTAssertFalse(isFake)
			XCTAssertEqual(count, 0)
			count += 1
			completion(.success(registrationToken))
		}

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 1)
			count += 1
			completion(.failure(.fakeResponse))
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		// Run test.

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.getRegistrationToken(forKey: .guid("test-key")) { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let token):
				XCTAssertEqual(token, registrationToken)
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_submitExposurePlaybook() {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegToken"
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

		// Run test.

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.isSubmissionConsentGiven = true

		service.getTemporaryExposureKeys { _ in
			service.submitExposure { error in
				expectation.fulfill()
				XCTAssertNil(error)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func test_fakeRequest() {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 3

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		let client = ClientMock()

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			count += 1
			completion(.failure(.fakeResponse))
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		// Run test.

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.fakeRequest()

		waitForExpectations(timeout: .short)
	}

	/// The fake registration token needs to comply to a format that is checked by the server.
	func test_fakeRegistrationTokenFormat() throws {
		let str = ENAExposureSubmissionService.fakeRegistrationToken
		let pattern = #"^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}$"#
		let regex = try NSRegularExpression(pattern: pattern, options: [])
		XCTAssertNotNil(regex.firstMatch(in: str, options: [], range: .init(location: 0, length: str.count)))
	}

	// MARK: - Private

	private func getTestResultPlaybookTest(with testResult: TestResult) {

		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let appConfigurationProvider = CachedAppConfigurationMock()
		let store = MockTestStore()
		let client = ClientMock()
		store.registrationToken = "dummyRegistrationToken"

		client.onGetTestResult = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertFalse(isFake)
			XCTAssertEqual(count, 0)
			count += 1
			completion(.success(testResult.rawValue))
		}

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 1)
			count += 1
			completion(.failure(.fakeResponse))
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		// Run test.

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keyRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		service.getTestResult { response in
			switch response {
			case .failure(let error):
				if testResult == .expired {
					XCTAssertEqual(error, .qrExpired)
				} else {
					XCTFail(error.localizedDescription)
				}

			case .success(let result):
				if testResult == .expired {
					XCTFail("Expired test result should lead to failure case")
				} else {
					XCTAssertEqual(result.rawValue, testResult.rawValue)
				}
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

}
