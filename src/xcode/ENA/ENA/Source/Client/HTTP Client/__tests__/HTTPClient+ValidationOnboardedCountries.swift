////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientValidationOnboardedCountriesTests: CWATestCase {
	
	func testGIVEN_Client_WHEN_HappyPath_THEN_PackageIsReturned() throws {
					
		// GIVEN
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-onboardedCountries", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["eTag": "\"SomeEtag\""],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		// WHEN
		var response: PackageDownloadResponse?
		let client = HTTPClient.makeWith(mock: stack)
		client.validationOnboardedCountries(completion: { result in
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
	
	
	func testGIVEN_Client_WHEN_SapPackageCouldNotBeCreated_THEN_Failure_InvalidResponseIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data())
		let client = HTTPClient.makeWith(mock: stack)
		let expectation = self.expectation(description: "completion handler is called with notModified failure")
		var failure: URLSession.Response.Failure?
		
		// WHEN
		client.validationOnboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				failure = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(failure, .invalidResponse)
	}
	
	func testGIVEN_Client_WHEN_NotModifiedContent_THEN_Failure_NotModifiedIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 304,
			responseData: Data())
		let client = HTTPClient.makeWith(mock: stack)
		let expectation = self.expectation(description: "completion handler is called with notModified failure")
		var failure: URLSession.Response.Failure?
		
		// WHEN
		client.validationOnboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				failure = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(failure, .notModified)
	}
	
	func testGIVEN_Client_WHEN_OtherHttpStatusCode_THEN_Failure_ServerErrorIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 504,
			responseData: Data())
		let client = HTTPClient.makeWith(mock: stack)
		let expectation = self.expectation(description: "completion handler is called with serverError failure")
		var failure: URLSession.Response.Failure?
		
		// WHEN
		client.validationOnboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				failure = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(failure, .serverError(504))
	}
	
	func testGIVEN_Client_WHEN_Failure_THEN_Failure_NoResponseIsReturned() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 504,
			responseData: nil)
		let client = HTTPClient.makeWith(mock: stack)
		let expectation = self.expectation(description: "completion handler is called with noResponse failure")
		var failure: URLSession.Response.Failure?
		
		// WHEN
		client.validationOnboardedCountries(completion: { result in
			switch result {
			case .success:
				XCTFail("This test should not succeed.")
			case let .failure(error):
				failure = error
				expectation.fulfill()
			}
		})
	
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(failure, .noResponse)
	}
	
	// MARK: - Private
	
	private let binFileSize = 50
	private let sigFileSize = 138
	private let expectationsTimeout: TimeInterval = 2
		
	private func assertPackageFormat(for response: PackageDownloadResponse) {
		XCTAssertFalse(response.isEmpty)
		XCTAssertNotNil(response.etag)
		XCTAssertEqual(response.package?.bin.count, binFileSize)
		XCTAssertEqual(response.package?.signature.count, sigFileSize)
	}
}
