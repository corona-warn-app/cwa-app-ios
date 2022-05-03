//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

final class HTTPClientDaysAndHoursTests: CWATestCase {
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

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
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
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never yield success")
			case .failure:
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchHour_InvalidPayload() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("hello world".utf8)
		)

		let expectation = expectation(description: "expect error result")

		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = FetchHourResource(day: "2020-05-01", country: "IT", hour: 1)
		restService.load(resource) { result in
			defer {
				expectation.fulfill()
			}
			switch result {
			case .success:
				XCTFail("an invalid response should never cause success")
			case let .failure(error):
				if case let .resourceError(detailError) = error,
				   case .packageCreation = detailError {
				} else {
					XCTFail("wrong error given, packageCreation expected")
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchHour_Success() throws {
		let url = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil))
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let expectation = expectation(description: "expect error result")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = FetchHourResource(day: "2020-05-01", country: "IT", hour: 1, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer {
				expectation.fulfill()
			}
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
		let url = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil))
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let resource = FetchDayResource(day: "2020-05-01", country: "IT", signatureVerifier: MockVerifier())
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
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

		let resource = FetchDayResource(day: "2020-05-01", country: "IT")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.load(resource) { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("An invalid server response should not result in success!")
			case let .failure(error):
				switch error {
				case .resourceError:
					break
				default:
					XCTFail("Incorrect error type \(error) received, expected .resourceError")
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
	
	private func assertPackageFormat(for response: PackageDownloadResponse) {
		// Packages for key download are never empty
		XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}
}
