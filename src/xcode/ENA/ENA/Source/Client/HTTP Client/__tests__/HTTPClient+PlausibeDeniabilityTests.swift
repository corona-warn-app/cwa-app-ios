//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class HTTPClientPlausibleDeniabilityTests: XCTestCase {

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

		client.getRegistrationToken(forKey: "123456789", withType: "TELETAN") { _ in expectation.fulfill() }
		client.getRegistrationToken(forKey: "123456789", withType: "TELETAN", isFake: true) { _ in expectation.fulfill() }

		waitForExpectations(timeout: .short)
	}

	func test_getTANForExposureSubmit_requestPadding() {

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

		client.getTANForExposureSubmit(forDevice: "dummyRegToken") { _ in expectation.fulfill() }
		client.getTANForExposureSubmit(forDevice: "dummyRegToken", isFake: true) { _ in expectation.fulfill() }

		waitForExpectations(timeout: .short)
	}

	/// This test makes sure that all headers + urls have the same length.
	func test_headerPadding() {

		// Setup.

		let expectation = self.expectation(description: "all callbacks called")
		expectation.expectedFulfillmentCount = 12

		var previousSize: Int?

		let session = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			expectation.fulfill()
			guard
				// Hack: We cannot directly access the HTTP headers here,
				// we therefore compare their JSON encoded lenght.
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

		client.getTANForExposureSubmit(forDevice: "dummyRegToken") { _ in expectation.fulfill() }
		client.getTANForExposureSubmit(forDevice: "dummyRegToken", isFake: true) { _ in expectation.fulfill() }
		client.getRegistrationToken(forKey: "123456789", withType: "TELETAN") { _ in expectation.fulfill() }
		client.getRegistrationToken(forKey: "123456789", withType: "TELETAN", isFake: true) { _ in expectation.fulfill() }
		client.getTestResult(forDevice: "dummyDevice") { _ in expectation.fulfill() }
		client.getTestResult(forDevice: "dummyDevice", isFake: true) { _ in expectation.fulfill() }

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
		let payload = CountrySubmissionPayload(exposureKeys: [], visitedCountries: [], eventCheckIns: [], tan: "dummyTan")
		realClient.submit(payload: payload, isFake: false, completion: { _ in expectation.fulfill() })
		fakeClient.submit(payload: payload, isFake: true, completion: { _ in expectation.fulfill() })

		waitForExpectations(timeout: .short)
		XCTAssertEqual(realRequestBodySize, fakeRequestBodySize)
	}
}
