//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class SRSKeySubmissionResourceTests: XCTestCase {

	let mockUrl = URL(staticString: "http://example.com")
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
		let stack = MockNetworkStack(
			httpStatus: 200,
			// cannot be nil since this is not a a completion handler can be in (response + nil body)
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// Act
		let payload = SubmissionPayload(
			exposureKeys: keys,
			visitedCountries: [],
			checkins: [],
			checkinProtectedReports: [],
			tan: nil,
			submissionType: .srsSelfTest
		)
				
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")
		
		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				break
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}
	
	func testSubmit_Request_SubmissionType() throws {
		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: nil, submissionType: .srsSelfTest)

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

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")

		restServiceProvider.load(resource) { _ in }

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testSubmit_SpecificError() {
		let stack = MockNetworkStack(
			mockSession: MockUrlSession(
				data: nil,
				nextResponse: nil,
				error: TestError.error
			)
		)
		let expectation = self.expectation(description: "SpecificError")

		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: nil, submissionType: .srsSelfTest)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("expected an error")
			case let .failure(error):
				switch error {
				case ServiceError.transportationError(let underLyingError):
					XCTAssertNotNil(underLyingError)
				default:
					XCTFail("We expect error to be of type other")
				}
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmit_ResponseNil() {
		let mockURLSession = MockUrlSession(data: nil, nextResponse: nil, error: nil)
		let stack = MockNetworkStack(
			mockSession: mockURLSession
		)
		let expectation = self.expectation(description: "ResponseNil")

		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: nil, submissionType: .srsSelfTest)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("expected an error")
			case let .failure(error):
				switch error {
				case .invalidResponseType:
					break
				default:
					XCTFail("We expect error to be of type other")
				}
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func testSubmit_Response400() {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let expectation = self.expectation(description: "Response400")

		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: nil, submissionType: .srsSelfTest)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("error expected")
			case let .failure(error):
				guard case ServiceError.receivedResourceError(.invalidPayloadOrHeader) = error else {
					XCTFail("We expect error to be of type invalidPayloadOrHeaders")
					return
				}
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func testSubmit_Response403() {
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: Data()
		)

		let expectation = self.expectation(description: "Response403")

		let payload = SubmissionPayload(exposureKeys: keys, visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: nil, submissionType: .srsSelfTest)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		
		let resource = SRSKeySubmissionResource(payload: payload, srsOtp: "Test")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("error expected")
			case let .failure(error):
				guard case ServiceError.receivedResourceError(.invalidOtp) = error else {
					XCTFail("We expect error to be of type invalidPayloadOrHeaders")
					return
				}
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
}
