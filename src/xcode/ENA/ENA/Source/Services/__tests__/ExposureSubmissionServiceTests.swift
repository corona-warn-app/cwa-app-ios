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

class ExposureSubmissionServiceTests: XCTestCase {
	let expectationsTimeout: TimeInterval = 2
	let keys = [ENTemporaryExposureKey()]

	func testSubmitExpousure_Success() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: nil)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "Success")
		var error: ExposureSubmissionError?

		// Act
		service.submitExposure {
			error = $0
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)

		// Assert
		XCTAssertNil(error)
	}

	func testSubmitExpousure_NoKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock(submissionError: nil)
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "NoKeys")

		// Act
		service.submitExposure { error in
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

	func testSubmitExpousure_EmptyKeys() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (nil, nil))
		let client = ClientMock(submissionError: nil)
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "EmptyKeys")

		// Act
		service.submitExposure { error in
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

	func testSubmitExpousure_InvalidTan() {
		// Arrange
		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: .invalidPayloadOrHeaders)
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "OtherError")

		// Act
		service.submitExposure { error in
			defer { expectation.fulfill() }
			guard let error = error else {
				XCTFail("error expected")
				return
			}
			guard case ExposureSubmissionError.other = error else {
				XCTFail("We expect error to be of type other")
				return
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmitExpousure_NoRegToken() {
		// Arrange

		let keyRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock(submissionError: nil)
		let store = MockTestStore()

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: keyRetrieval, client: client, store: store)
		let expectation = self.expectation(description: "InvalidRegToken")

		// Act
		service.submitExposure {error in
			defer {
				expectation.fulfill()
			}
			XCTAssert(error == .noRegistrationToken)
		}

		waitForExpectations(timeout: expectationsTimeout)
	}
}
