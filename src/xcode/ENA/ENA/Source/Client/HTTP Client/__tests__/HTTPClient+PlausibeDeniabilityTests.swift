//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class HTTPClientPlausibleDeniabilityTests: CWATestCase {

	func test_getTestResult_requestPadding() {

		// GIVEN
		let sendResource = PaddingJSONSendResource<TestResultSendModel>(
			TestResultSendModel(
				registrationToken: "123456789"
			)
		)

		// WHEN
		let result = sendResource.encode()

		// THEN
		switch result {
		case let .success(bodyData):
			XCTAssertEqual(bodyData?.count, 250)
		case .failure:
			XCTFail("Padding size is wrong")
		}
	}

	func test_getRegistrationToken_requestPadding() {
		// GIVE
		let sendResource = PaddingJSONSendResource<KeyModel>(
			KeyModel(
				key: "123456789",
				keyType: .teleTan
			)
		)

		// WHEN
		let result = sendResource.encode()

		// THEN
		switch result {
		case let .success(bodyData):
			XCTAssertEqual(bodyData?.count, 250)
		case .failure:
			XCTFail("Padding size is wrong")
		}
	}

	func test_getTANForExposureSubmit_requestPadding() {
		
		let sendResource = PaddingJSONSendResource<RegistrationTokenSendModel>(
			RegistrationTokenSendModel(token: "dummyRegToken")
		)
		if case let .success(bodyData) = sendResource.encode() {
			do {
				let data = try XCTUnwrap(bodyData)
				XCTAssertEqual(data.count, 250)
			} catch {
				XCTFail("Should unwrap data object \(error.localizedDescription)")
			}
		} else {
			XCTFail("Wrong padding body size")
		}
	}

	func test_submit_requestPaddingIdenticalForRealAndFake() {
		let noKeys = [ENTemporaryExposureKey]()
		compareSubmitRequestPadding(for: noKeys)

		let lessThan14Keys = (0..<11).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: lessThan14Keys)

		let exactly14Keys = (0..<14).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: exactly14Keys)

		let moreThan14Keys = (0..<23).map { _ in ENTemporaryExposureKey() }
		compareSubmitRequestPadding(for: moreThan14Keys)
	}

	private func compareSubmitRequestPadding(for keys: [ENTemporaryExposureKey]) {

		// Setup.
		var realRequestBodySize = Int.max
		var fakeRequestBodySize = Int.min

		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 4

		let realSession = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			expectation.fulfill()
			realRequestBodySize = request.httpBody?.count ?? 1
		}

		let fakeSession = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			expectation.fulfill()
			fakeRequestBodySize = request.httpBody?.count ?? -1
		}

		let realStack = MockNetworkStack(mockSession: realSession)
		let fakeStack = MockNetworkStack(mockSession: fakeSession)

		let realClient = HTTPClient.makeWith(mock: realStack)
		let fakeClient = HTTPClient.makeWith(mock: fakeStack)

		// Test.
		let payload = SubmissionPayload(exposureKeys: [], visitedCountries: [], checkins: [], checkinProtectedReports: [], tan: "dummyTan", submissionType: .pcrTest)
		realClient.submit(payload: payload, isFake: false, completion: { _ in expectation.fulfill() })
		fakeClient.submit(payload: payload, isFake: true, completion: { _ in expectation.fulfill() })

		waitForExpectations(timeout: .short)
		XCTAssertEqual(realRequestBodySize, fakeRequestBodySize)
	}
}
