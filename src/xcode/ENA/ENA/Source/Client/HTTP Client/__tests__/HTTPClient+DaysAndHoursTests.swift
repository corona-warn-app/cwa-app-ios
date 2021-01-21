//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

// swiftlint:disable:next type_body_length
final class HTTPClientDaysAndHoursTests: XCTestCase {
	let binFileSize = 501
	let sigFileSize = 144
	let mockUrl = URL(staticString: "http://example.com")
	let tan = "1234"

	private var keys: [ENTemporaryExposureKey] {
		let key = ENTemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

	func testAvailableDays_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("[\"2020-05-01\", \"2020-05-02\"]".utf8)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		HTTPClient.makeWith(mock: stack).availableDays(forCountry: "IT") { result in
			switch result {
			case let .success(days):
				XCTAssertEqual(
					days,
					["2020-05-01", "2020-05-02"]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testAvailableDays_StatusCodeNotAccepted() {
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data(
				"""
				["2020-05-01", "2020-05-02"]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).availableDays(forCountry: "IT") { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never yield success")
			case .failure:
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .medium)
	}

	// The hours of a given day can be missing
	func testAvailableHours_NotFound() {
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data(
				"""
				[1,2,3,4,5]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect successful result but empty"
		)

		let httpClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		httpClient.availableHours(day: "2020-05-12", country: "IT") { result in
			switch result {
			case let .success(hours):
				XCTAssertEqual(
					hours,
					[]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testAvailableHours_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(
				"""
				[1,2,3,4,5]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		let httpClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		httpClient.availableHours(day: "2020-05-12", country: "IT") { result in
			switch result {
			case let .success(hours):
				XCTAssertEqual(
					hours,
					[1, 2, 3, 4, 5]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yield an error like \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchHour_InvalidPayload() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("hello world".utf8)
		)

		let failureExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		httpClient.fetchHour(1, day: "2020-05-01", country: "IT") { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never cause success")
			case .failure:
				failureExpectation.fulfill()
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchHour_Success() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		httpClient.fetchHour(1, day: "2020-05-01", country: "IT") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchDay_Success() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.fetchDay("2020-05-01", forCountry: "IT") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchDay_InvalidPackage() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.fetchDay("2020-05-01", forCountry: "IT") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("An invalid server response should not result in success!")
			case let .failure(error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("Incorrect error type \(error) received, expected .invalidResponse")
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

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
		let client = HTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchDay("2020-0-0", forCountry: "XXX") { result in
			switch result {
			case .failure(let error):
				if case .noResponse = error {
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
		let client = HTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchDay("2020-0-0", forCountry: "XXX") { result in
			switch result {
			case .failure(let error):
				if case .invalidResponse = error {
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
		let client = HTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchDay("2020-0-0", forCountry: "XXX") { result in
			switch result {
			case .failure(let error):
				XCTFail("expected no error, got \(error)")
			case .success(let package):
				self.assertPackageFormat(for: package)
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	func testDownloadRetry_hourPackage_failing() throws {
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
		let client = WifiOnlyHTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchHour(1, day: "2020-0-0", country: "XXX") { result in
			switch result {
			case .failure(let error):
				if case .noResponse = error {
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

	func testDownloadRetry_hourPackage_invalidResponse() throws {
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
		let client = WifiOnlyHTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchHour(1, day: "2020-0-0", country: "XXX") { result in
			switch result {
			case .failure(let error):
				if case .invalidResponse = error {
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

	func testDownloadRetry_hourPackage_succeeding() throws {
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
		let client = WifiOnlyHTTPClient.makeWith(mock: stack)
		// We mock the connection, no need for read data!
		client.fetchHour(1, day: "2020-0-0", country: "XXX") { result in
			switch result {
			case .failure(let error):
				XCTFail("expected no error, got \(error)")
			case .success(let package):
				self.assertPackageFormat(for: package)
			}
		}

		waitForExpectations(timeout: 10, handler: nil)
	}

	private func assertPackageFormat(for response: PackageDownloadResponse) {
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package.bin.count, binFileSize)
		XCTAssertEqual(response.package.signature.count, sigFileSize)
	}
}
