//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

// swiftlint:disable:next type_body_length
class CoronaTestServiceTests: XCTestCase {

	// MARK: - Test Result

	func testUpdatePCRTestResult_success() {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.positive.rawValue))
		}

		let service = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testUpdateAntigenTestResult_success() {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.positive.rawValue))
		}

		let service = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.antigenTest = AntigenTest.mock(registrationToken: "regToken")

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testUpdatePCRTestResult_noCoronaTestOfRequestedType() {
		let service = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noCoronaTestOfRequestedType)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdateAntigenTestResult_noCoronaTestOfRequestedType() {
		let service = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.antigenTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noCoronaTestOfRequestedType)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdatePCRTestResult_noRegistrationToken() {
		let service = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = PCRTest.mock(registrationToken: nil)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
	}

	func testUpdateAntigenTestResult_noRegistrationToken() {
		let service = CoronaTestService(
			client: ClientMock(),
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.antigenTest = AntigenTest.mock(registrationToken: nil)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
	}

	// MARK: - Test Registration

	func testRegisterPCRTestAndGetResult_successWithoutSubmissionConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let client = ClientMock()
		client.onGetRegistrationToken = { _, _, _, completion in
			completion(.success("registrationToken"))
		}

		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.pending.rawValue))
		}

		let service = CoronaTestService(
			client: client,
			store: store,
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			isSubmissionConsentGiven: false
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
		XCTAssertFalse(pcrTest.positiveTestResultWasShown)
		XCTAssertFalse(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertFalse(pcrTest.journalEntryCreated)

		XCTAssertEqual(store.testResultMetadata?.testResult, .pending)
		XCTAssertEqual(
			try XCTUnwrap(store.testResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterPCRTestAndGetResult_successWithSubmissionConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let client = ClientMock()
		client.onGetRegistrationToken = { _, _, _, completion in
			completion(.success("registrationToken2"))
		}

		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.negative.rawValue))
		}

		let service = CoronaTestService(
			client: client,
			store: store,
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			isSubmissionConsentGiven: true
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken2")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertFalse(pcrTest.positiveTestResultWasShown)
		XCTAssertTrue(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertFalse(pcrTest.journalEntryCreated)

		XCTAssertEqual(store.testResultMetadata?.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(store.testResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func test_When_UpatePresentNotificationTrue_Then_NotificationShouldBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.positive.rawValue))
		}

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
	}

	func test_When_UpatePresentNotificationFalse_Then_NotificationShouldNOTBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.positive.rawValue))
		}

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: false) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpateTestResultsFails_Then_ErrorIsReturned() {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.invalidResponse))
		}

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: MockUserNotificationCenter()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { result in
			if case .success = result {
				XCTFail("Success not expected")
			}
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_When_UpateTestResultsSuccessWithPending_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.pending.rawValue))
		}

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpateTestResultsSuccessWithExpired_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(TestResult.expired.rawValue))
		}

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateWithForce_And_FinalTestResultExist_Then_ClientIsCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(TestResult.expired.rawValue))
		}

		testService.updateTestResults(force: true, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_FinalTestResultExist_Then_ClientIsNotCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		client.onGetTestResult = { _, _, _ in
			getTestResultExpectation.fulfill()
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_NoFinalTestResultExist_Then_ClientIsCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let testService = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: mockNotificationCenter
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(TestResult.expired.rawValue))
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	// MARK: - Plausible Deniability

	func test_getTestResultPlaybookPositive() {
		getTestResultPlaybookTest(for: .pcr, with: .positive)
		getTestResultPlaybookTest(for: .antigen, with: .positive)
	}

	func test_getTestResultPlaybookNegative() {
		getTestResultPlaybookTest(for: .pcr, with: .negative)
		getTestResultPlaybookTest(for: .antigen, with: .negative)
	}

	func test_getTestResultPlaybookPending() {
		getTestResultPlaybookTest(for: .pcr, with: .pending)
		getTestResultPlaybookTest(for: .antigen, with: .pending)
	}

	func test_getTestResultPlaybookInvalid() {
		getTestResultPlaybookTest(for: .pcr, with: .invalid)
		getTestResultPlaybookTest(for: .antigen, with: .invalid)
	}

	func test_getTestResultPlaybookExpired() {
		getTestResultPlaybookTest(for: .pcr, with: .expired)
		getTestResultPlaybookTest(for: .antigen, with: .expired)
	}

	// MARK: - Private

	private func getTestResultPlaybookTest(for coronaTestType: CoronaTestType, with testResult: TestResult) {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let client = ClientMock()

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

		let service = CoronaTestService(
			client: client,
			store: MockTestStore(),
			appConfiguration: CachedAppConfigurationMock()
		)
		service.pcrTest = PCRTest.mock(registrationToken: "regToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "regToken")

		// Run test.

		service.updateTestResult(for: coronaTestType) { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let result):
				XCTAssertEqual(result.rawValue, testResult.rawValue)
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

 	private func mockRiskCalculationResult() -> ENFRiskCalculationResult {
 		ENFRiskCalculationResult(
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

	// swiftlint:disable:next file_length
}
