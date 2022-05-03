//
// 🦠 Corona-Warn-App
//

import XCTest

class FetchDayRetryTests: CWATestCase {

	func testDownloadRetry_dayPackage_failing() throws {
		let expectation = self.expectation(description: "http request")
		expectation.expectedFulfillmentCount = 4 // initial request + 3 retries

		// just failing...
		let response = HTTPURLResponse(
			// swiftlint:disable:next force_unwrapping
			url: URL(string: "https://example.com")!,
			statusCode: 500,
			httpVersion: "HTTP/2",
			headerFields: nil)
		let session = MockUrlSession(data: nil, nextResponse: response, error: nil) { request in
			expectation.fulfill()
			Log.debug(request.debugDescription)
		}

		let stack = MockNetworkStack(mockSession: session)

		// We mock the connection, no need for read data!
		let resource = FetchDayResource(day: "2020-0-0", country: "XXX", signatureVerifier: MockVerifier())
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			switch result {
			case .failure(let error):
				if case ServiceError<Error>.unexpectedServerError(500) = error {
					break // ok
				} else {
					XCTFail("expected `.noResponse` error, got \(error)")
				}
			case .success(let package):
				XCTFail("Expected no success! Got \(package)")
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testDownloadRetry_dayPackage_invalidResponse() throws {
		let requestDone = expectation(description: "http request")
		requestDone.expectedFulfillmentCount = 4 // initial request + 3 retries

		var retryCount = 0

		// prepare responses
		let failingResponse = HTTPURLResponse(
			// swiftlint:disable:next force_unwrapping
			url: URL(string: "https://example.com")!,
			statusCode: 500,
			httpVersion: "HTTP/2",
			headerFields: nil)
		let successfulResponse = HTTPURLResponse(
			// swiftlint:disable:next force_unwrapping
			url: URL(string: "https://example.com")!,
			statusCode: 200,
			httpVersion: "HTTP/2",
			headerFields: nil)

		// setup session that fails on 2 requests and succeeds in the 3rd
		let session = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			Log.debug("\(request.debugDescription) - retries: \(retryCount)")
			requestDone.fulfill()
			retryCount += 1
		}
		session.onPrepareResponse = {
			if retryCount < 2 {
				session.data = nil
				session.nextResponse = failingResponse
			} else {
				// Client gets something but not as expected.
				session.data = "invalid payload".data(using: .utf8)
				session.nextResponse = successfulResponse
			}
		}
		let stack = MockNetworkStack(mockSession: session)

		// We mock the connection, no need for read data!
		let resource = FetchDayResource(day: "2020-0-0", country: "XXX")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			switch result {
			case .failure(let error):
				if case ServiceError<Error>.invalidResponse = error {
					break // ok
				} else {
					XCTFail("expected `.invalidResponse` error, got \(error)")
				}
			case .success(let package):
				XCTFail("Expected no success! Got \(package)")
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testDownloadRetry_dayPackage_succeeding() throws {
		let requestDone = expectation(description: "http request")
		requestDone.expectedFulfillmentCount = 3

		var retryCount = 0

		// prepare responses
		let failingResponse = HTTPURLResponse(
			// swiftlint:disable:next force_unwrapping
			url: URL(string: "https://example.com")!,
			statusCode: 500,
			httpVersion: "HTTP/2",
			headerFields: nil
		)
		let successfulResponse = HTTPURLResponse(
			// swiftlint:disable:next force_unwrapping
			url: URL(string: "https://example.com")!,
			statusCode: 200,
			httpVersion: "HTTP/2",
			headerFields: ["etAg": "\"SomeEtag\""]
		)
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
		let validPayload = try Data(contentsOf: url)


		// setup session that fails on 2 requests and succeeds in the 3rd
		let session = MockUrlSession(data: nil, nextResponse: nil, error: nil) { request in
			Log.debug("\(request.debugDescription) - retries: \(retryCount)")
			requestDone.fulfill()
			retryCount += 1
		}
		session.onPrepareResponse = {
			if retryCount < 3 {
				session.data = nil
				session.nextResponse = failingResponse
			} else {
				session.data = validPayload
				session.nextResponse = successfulResponse
			}
		}

		let stack = MockNetworkStack(mockSession: session)
		// We mock the connection, no need for read data!
		let resource = FetchDayResource(day: "2020-0-0", country: "XXX")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			switch result {
			case .failure(let error):
				XCTFail("expected no error, got \(error)")
			case .success(let package):
				self.assertPackageFormat(for: package)
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

}
