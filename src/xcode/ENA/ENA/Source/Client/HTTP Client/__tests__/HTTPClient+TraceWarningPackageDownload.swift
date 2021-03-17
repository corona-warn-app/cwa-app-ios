////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDownload: XCTestCase {
	
	// MARK: - Tests
	
	func testGIVEN_CountryAndPackageId_WHEN_HappyCase_THEN_TraceWarningPackageIsReturned() throws {

		// GIVEN
		let packageId = Date().unixTimestampInHours
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-traceWarning", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: PackageDownloadResponse?
		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.traceWarningPackageDownload(country: "DE", packageId: packageId, completion: { result in
			switch result {
			case let .success(package):
				response = package
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertNotNil(response)
		self.assertPackageFormat(for: try XCTUnwrap(response))
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_EmptyHeaderIsSend_THEN_EmptyTraceWarningPackageIsReturned() throws {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-traceWarning", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\"", "cwa-empty-pkg": "1"],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: PackageDownloadResponse?
		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.traceWarningPackageDownload(country: "DE", packageId: packageId, completion: { result in
			switch result {
			case let .success(package):
				response = package
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertNotNil(response)
		self.assertPackageFormat(for: try XCTUnwrap(response), isEmpty: true)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_ReferenceIsKilled_THEN_DownloadErrorIsReturned() {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: TraceWarningError?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDownload(country: "DE", packageId: packageId, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				response = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(response, .downloadError)
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_PackageIsInvalid_THEN_InvalidResponseErrorIsReturned() {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: TraceWarningError?
		let httpClientMock = HTTPClient.makeWith(mock: stack)
		httpClientMock.traceWarningPackageDownload(country: "DE", packageId: packageId, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				response = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(response, .invalidResponseError(200))
	}
	
	func testGIVEN_CountryAndPackageId_WHEN_EmptyResponse_THEN_InvalidResponseErrorIsReturned() {
		
		// GIVEN
		let packageId = Date().unixTimestampInHours
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: nil
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var response: TraceWarningError?
		let httpClientMock = HTTPClient.makeWith(mock: stack)
		httpClientMock.traceWarningPackageDownload(country: "DE", packageId: packageId, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success!")
			case let .failure(error):
				response = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(response, .defaultServerError(URLSession.Response.Failure.noResponse))
	}
	
	// MARK: - Private
	
	private let binFileSize = 501
	private let sigFileSize = 144
	private let expectationsTimeout: TimeInterval = 2
		
	private func assertPackageFormat(for response: PackageDownloadResponse, isEmpty: Bool = false) {
		guard let responseIsEmpty = response.isEmpty else {
			XCTFail("isEmpty should not be nil")
			return
		}
		isEmpty ? XCTAssertTrue(responseIsEmpty) : XCTAssertFalse(responseIsEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package.bin.count, binFileSize)
		XCTAssertEqual(response.package.signature.count, sigFileSize)
	}
}
