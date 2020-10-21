// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import ENA
import ExposureNotification
import XCTest


// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureSubmissionServiceTests: XCTestCase {
	let expectationsTimeout: TimeInterval = 2
	let keys = [ENTemporaryExposureKey()]

	// MARK: - Exposure Submission Tests

	func testSubmitExposure_Success() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "Success")

		// Act
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) {
			// no `ExposureSubmissionError`
			XCTAssertNil($0)
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmitExposure_NoKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "NoKeys")

		// Act
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			defer { expectation.fulfill() }
			guard let error = error else {
				XCTFail("error expected")
				return
			}
			guard case ExposureSubmissionError.noKeys = error else {
				XCTFail("We expect error to be of type expectationsTimeout")
				return
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmitExposure_EmptyKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock()
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "EmptyKeys")

		// Act
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			defer { expectation.fulfill() }
			guard let error = error else {
				XCTFail("error expected")
				return
			}
			guard case ExposureSubmissionError.noKeys = error else {
				XCTFail("We expect error to be of type noKeys")
				return
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testExposureSubmission_InvalidPayloadOrHeaders() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "invalidPayloadOrHeaders Error")

		// Act
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			defer { expectation.fulfill() }
			guard let error = error else {
				XCTFail("error expected")
				return
			}

			guard case ExposureSubmissionError.invalidPayloadOrHeaders = error else {
				XCTFail("We expect error to be of type invalidPayloadOrHeaders")
				return
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmitExposure_NoRegToken() {
		// Arrange

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "InvalidRegToken")

		// Act
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) {error in
			defer {
				expectation.fulfill()
			}
			XCTAssertEqual(error, .noRegistrationToken)
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTestResult_success() {

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
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
		let service = ENAExposureSubmissionService(
			diagnosiskeyRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			client: ClientMock(),
			store: MockTestStore()
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
		let service = ENAExposureSubmissionService(
			diagnosiskeyRetrieval: MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil)),
			client: ClientMock(),
			store: MockTestStore()
		)

		// Execute test.
		service.getTestResult(forKey: DeviceRegistrationKey.guid("wrong"), useStoredRegistration: false) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testGetTestResult_expiredTestResultValue() {
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let client = ClientMock()
		client.onGetTestResult = { _, _, completeWith in
			let expiredTestResultValue = 4
			completeWith(.success(expiredTestResultValue))
		}

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
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
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let client = ClientMock()
		client.onGetTestResult = { _, _, completeWith in
			let unknownTestResultValue = 5
			completeWith(.success(unknownTestResultValue))
		}

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
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

	func testCorrectErrorForRequestCouldNotBeBuilt() {

		// Initialize.
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .requestCouldNotBeBuilt)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)

		// Execute test.
		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - The submission request could not be built correctly."

		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			expectation.fulfill()
			XCTAssertEqual(error?.localizedDescription, controlTest)
		}

		waitForExpectations(timeout: .short)
	}

	func testCorrectErrorForInvalidPayloadOrHeaders() {

		// Initialize.
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		let expectation = self.expectation(description: "Correct error description received.")
		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)

		// Execute test.
		let controlTest = "\(AppStrings.ExposureSubmissionError.errorPrefix) - Received an invalid payload or headers."

		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			expectation.fulfill()
			XCTAssertEqual(error?.localizedDescription, controlTest)
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
		let store = MockTestStore()
		store.registrationToken = registrationToken

		// Force submission error. (Which should result in a 4xx, not a 5xx!)
		let client = ClientMock(submissionError: .serverError(500))
		client.onGetTANForExposureSubmit = { _, _, completion in completion(.success(tan)) }

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 2

		// Execute test.

		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { result in
			expectation.fulfill()
			XCTAssertNotNil(result)

			// Retry.
			client.onSubmitCountries = { $2(.success(())) }
			client.onGetTANForExposureSubmit = { _, isFake, completion in
				XCTAssertTrue(isFake, "When executing the real request, instead of using the stored TAN, we have made a request to the server.")
				completion(.failure(.fakeResponse))
			}
			service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { result in
				expectation.fulfill()
				XCTAssertNil(result)
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testServiceHelperFunctions() throws {
		let client = ClientMock()
		let registrationToken = "dummyRegistrationToken"

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let store = MockTestStore()
		store.registrationToken = registrationToken

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		XCTAssertTrue(service.hasRegistrationToken())

		service.deleteTest()
		XCTAssertFalse(service.hasRegistrationToken())
	}

	// MARK: Plausible deniability tests.

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

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
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

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		service.submitExposure(symptomsOnset: .noInformation, visitedCountries: []) { error in
			expectation.fulfill()
			XCTAssertNil(error)
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

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		service.fakeRequest()

		waitForExpectations(timeout: .short)
	}

	/// The fake registration token needs to comply to a format that is checked by the server.
	func test_fakeRegistrationTokenFormat() {
		let str = ENAExposureSubmissionService.fakeRegistrationToken
		let pattern = #"^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}$"#
		let regex = try? NSRegularExpression(pattern: pattern, options: [])
		XCTAssertNotNil(regex?.firstMatch(in: str, options: [], range: .init(location: 0, length: str.count)))
	}

	// MARK: - Private

	private func getTestResultPlaybookTest(with testResult: TestResult) {

		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let store = MockTestStore()
		let client = ClientMock()
		store.registrationToken = "dummyRegistrationToken"

		client.onGetTestResult = { result, isFake, completion in
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

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
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
