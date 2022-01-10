//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import ExposureNotification
import XCTest

final class HTTPClientSubmitTests: CWATestCase {

	let mockUrl = URL(staticString: "http://example.com")
	let expectationsTimeout: TimeInterval = 2
	let tan = "1234"

	private var keys: [SAP_External_Exposurenotification_TemporaryExposureKey] {
		var key = SAP_External_Exposurenotification_TemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartIntervalNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

	func testSubmit_Success() {
		// Arrange
		let stack = MockNetworkStack(
			httpStatus: 200,
			// cannot be nil since this is not a a completion handler can be in (response + nil body)
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)

		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false, completion: { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				break
			}
			expectation.fulfill()
		})

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_Request_SubmissionType() throws {
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .rapidTest)

		let expectation = self.expectation(description: "completion handler is called without an error")

		let stack = MockNetworkStack(
			httpStatus: 200,
			// cannot be nil since this is not a a completion handler can be in (response + nil body)
			responseData: Data(),
			requestObserver: { request in
				print(request)

				guard let protoPayload = try? SAP_Internal_SubmissionPayload(serializedData: request.httpBody ?? Data()) else {
					XCTFail("Request data expected to be serializable to protobuf.")
					return
				}

				XCTAssertEqual(protoPayload.submissionType, payload.submissionType)

				expectation.fulfill()
			}
		)

		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false, completion: { _ in })

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_Error() {
		// Arrange
		let stack = MockNetworkStack(
			mockSession: MockUrlSession(
				data: nil,
				nextResponse: nil,
				error: TestError.error
			)
		)

		let expectation = self.expectation(description: AppStrings.ExposureSubmission.generalErrorTitle)

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)
		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: true) { response in
			switch response {
			case .failure:
				break // no further checks here
			case .success:
				XCTFail("expected an error")
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_SpecificError() {
		// Arrange
		let stack = MockNetworkStack(
			mockSession: MockUrlSession(
				data: nil,
				nextResponse: nil,
				error: TestError.error
			)
		)
		let expectation = self.expectation(description: "SpecificError")

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)
		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false) { response in
			switch response {
			case .failure(let error):
				switch error {
				case SubmissionError.other(let underLyingError):
					XCTAssertNotNil(underLyingError)
				default:
					XCTFail("We expect error to be of type other")
				}
			case .success:
				XCTFail("expected an error")
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_ResponseNil() {
		// Arrange
		let mockURLSession = MockUrlSession(data: nil, nextResponse: nil, error: nil)
		let stack = MockNetworkStack(
			mockSession: mockURLSession
		)
		let expectation = self.expectation(description: "ResponseNil")

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)
		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false) { response in
			switch response {
			case .failure(let error):
				switch error {
				case SubmissionError.other(_):
					break // this is what we want
				default:
					XCTFail("We expect error to be of type other")
				}
			case .success:
				XCTFail("expected an error")
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_Response400() {
		// Arrange
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let expectation = self.expectation(description: "Response400")

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)
		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false) { response in
			defer { expectation.fulfill() }

			switch response {
			case .failure(let error):
				guard case SubmissionError.invalidPayloadOrHeaders = error else {
					XCTFail("We expect error to be of type invalidPayloadOrHeaders")
					return
				}
			default:
				XCTFail("error expected")
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	func testSubmit_Response403() {
		// Arrange
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: Data()
		)

		let expectation = self.expectation(description: "Response403")

		// Act
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: tan, submissionType: .pcrTest)
		HTTPClient.makeWith(mock: stack).submit(payload: payload, isFake: false) { response in
			defer { expectation.fulfill() }

			switch response {
			case .failure(let error):
				guard case SubmissionError.invalidTan = error else {
					XCTFail("We expect error to be of type invalidPayloadOrHeaders")
					return
				}
			default:
				XCTFail("error expected")
			}
		}

		waitForExpectations(timeout: expectationsTimeout)
	}
}
