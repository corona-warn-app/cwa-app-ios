////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDownloadTests: CWATestCase {
	
	// MARK: - Tests
	
	func testGIVEN_CountryAndPackageId_WHEN_HappyCase_THEN_TraceWarningPackageIsReturned() throws {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-traceWarning", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)

		let expectation = expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(package):
				self.assertPackageFormat(for: package)

			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}

		}

		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_EmptyContentHeaderIsSend_THEN_EmptyTraceWarningPackageIsReturned() throws {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "0"],
			responseData: Data()
		)

		let expectation = expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(package):
				XCTAssertNotNil(package)
				XCTAssertTrue(package.isEmpty)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_ReferenceIsKilled_THEN_DownloadErrorIsReturned() {
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDownloadResource(unencrypted: true, country: "DE", packageId: packageId, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				if let customError = resource.customError(for: error),
				   customError == .generalError {
					XCTAssertTrue(true)
				}
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_PackageIsInvalid_THEN_InvalidResponseErrorIsReturned() {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: TraceWarningError?
		/*
		let httpClientMock = HTTPClient.makeWith(mock: stack)
		httpClientMock.traceWarningPackageDownload(unencrypted: true, country: "DE", packageId: packageId, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				response = error
				expectation.fulfill()
			}
		})
		 */

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(response, .invalidResponseError)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_EmptyResponse_THEN_InvalidResponseErrorIsReturned() {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "content-length": "1"],
			responseData: nil
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: TraceWarningError?
		/*
		let httpClientMock = HTTPClient.makeWith(mock: stack)
		httpClientMock.traceWarningPackageDownload(unencrypted: true, country: "DE", packageId: packageId, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				response = error
				expectation.fulfill()
			}
		})
		 */

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(response, .defaultServerError(URLSession.Response.Failure.noResponse))
	}
	
	// MARK: - Private
	
	private let binFileSize = 50
	private let sigFileSize = 138
	private let expectationsTimeout: TimeInterval = 2
		
	private func assertPackageFormat(for response: PackageDownloadResponse, isEmpty: Bool = false) {
		// Packages for trace warnings can be empty if special http header is send.
		isEmpty ? XCTAssertTrue(response.isEmpty) : XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}
}
