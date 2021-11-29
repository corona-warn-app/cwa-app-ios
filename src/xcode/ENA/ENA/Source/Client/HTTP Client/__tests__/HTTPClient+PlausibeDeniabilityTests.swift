//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class HTTPClientPlausibleDeniabilityTests: CWATestCase {

	func test_getTestResult_requestPadding() {

		// Setup.

		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 4
		let session = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			expectation.fulfill()
			XCTAssertEqual(request.httpBody?.count, 250)
		}

		let stack = MockNetworkStack(mockSession: session)
		let client = HTTPClient.makeWith(mock: stack)

		// Test.

		client.getTestResult(forDevice: "dummyDevice") { _ in expectation.fulfill() }
		client.getTestResult(forDevice: "dummyDevice", isFake: true) { _ in expectation.fulfill() }
		waitForExpectations(timeout: .short)
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
		
		let sendResource = PaddingJSONSendResource<SendRegistrationTokenModel>(
			SendRegistrationTokenModel(token: "dummyRegToken")
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

	// This test makes sure that all headers + urls have the same length.
	// That test should check for all requests with padding later
	func test_headerPadding() {

		// Setup.
		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 6

		var previousSize: Int?

		let session = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			expectation.fulfill()
			guard
				// Hack: We cannot directly access the HTTP headers here,
				// we therefore compare their JSON encoded length.
				let data = try? JSONEncoder().encode(request.allHTTPHeaderFields),
				let url = request.url?.absoluteString
			else {
				XCTFail("Could not execute test")
				return
			}
			let size = url.count + data.count
			if previousSize == nil { previousSize = size }
			XCTAssertEqual(size, previousSize)
			previousSize = size
		}

		let stack = MockNetworkStack(mockSession: session)
		let client = HTTPClient.makeWith(mock: stack)

		// Test.
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(SubmissionTANModel(submissionTAN: "fake")),
				.success(SubmissionTANModel(submissionTAN: "fake"))
			]
		)
		let resource = RegistrationTokenResource(
			sendModel: SendRegistrationTokenModel(
				token: "dummyRegToken"
			)
		)
		restServiceProvider.load(resource) { _ in
			expectation.fulfill()
		}
		let fakeRequestResource = RegistrationTokenResource(
			isFake: true,
			sendModel: SendRegistrationTokenModel(
				token: "dummyRegToken"
			)
		)

		restServiceProvider.load(fakeRequestResource) { _ in
			expectation.fulfill()
		}
		
		client.getTestResult(forDevice: "dummyDevice") { _ in
			expectation.fulfill()
		}
		client.getTestResult(forDevice: "dummyDevice", isFake: true) { _
			in expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
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
