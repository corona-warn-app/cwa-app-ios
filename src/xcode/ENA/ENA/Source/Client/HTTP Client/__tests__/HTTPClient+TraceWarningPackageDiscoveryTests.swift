////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDiscoveryTests: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_Country_WHEN_HappyCase_THEN_TraceWarningDiscoveryIsReturned() throws {

		// GIVEN
		let oldest = 448520
		let latest = 448522
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: oldest, latest: latest))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		let expectedResponse = TraceWarningDiscovery(oldest: oldest, latest: latest, eTag: "FakeETag")
		
		// WHEN
		var response: TraceWarningDiscovery?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(country: "DE", completion: { result in
			switch result {
			case let .success(traceWarningDiscovery):
				response = traceWarningDiscovery
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(response)
		XCTAssertEqual(response?.oldest, expectedResponse.oldest)
		XCTAssertEqual(response?.latest, expectedResponse.latest)
		XCTAssertEqual(response?.availablePackagesOnCDN, expectedResponse.availablePackagesOnCDN)
	}
	
	func testGIVEN_Country_WHEN_ResponseIsMissing_THEN_DefaultServerErrorIsReturned() throws {

		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		// WHEN
		var responseError: TraceWarningError?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(country: "DE", completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed")
			case let .failure(error):
				responseError = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(responseError, TraceWarningError.defaultServerError(URLSession.Response.Failure.noResponse))
	}
	
	func testGIVEN_Country_WHEN_OldestLatestAreNil_THEN_OneAvailablePackagesOnCDNAreReturned() throws {

		// GIVEN
		let oldest = 448520
		let latest = 448520
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: oldest, latest: latest))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		let expectedResponse = TraceWarningDiscovery(oldest: oldest, latest: latest, eTag: "FakeETag")
		
		// WHEN
		var response: TraceWarningDiscovery?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(country: "DE", completion: { result in
			switch result {
			case let .success(traceWarningDiscovery):
				response = traceWarningDiscovery
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(response)
		XCTAssertEqual(response?.oldest, expectedResponse.oldest)
		XCTAssertEqual(response?.latest, expectedResponse.latest)
		XCTAssertEqual(response?.availablePackagesOnCDN, expectedResponse.availablePackagesOnCDN)
		XCTAssertEqual(response?.availablePackagesOnCDN.count, 1)
	}
	
	func testGIVEN_Country_WHEN_OldestLatestAreNil_THEN_EmptyAvailablePackagesOnCDNAreReturned() throws {

		// GIVEN
		let jsonEncoder = JSONEncoder()
		// At least, one of the two must be nil to trigger an empty package response
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: nil, latest: 33333))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		// WHEN
		var expectedResponse: TraceWarningDiscovery?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(country: "DE", completion: { result in
			switch result {
			case let .success(traceWarningDiscovery):
				expectedResponse = traceWarningDiscovery
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		guard let response = expectedResponse else {
			XCTFail("Response should not be nil")
			return
		}
		// If oldest or latest are nil, we expect for oldest 0 and latest -1. See also in HTTPClient, method traceWarningPackageDiscovery.
		XCTAssertEqual(response.oldest, 0)
		XCTAssertEqual(response.latest, -1)
		XCTAssertTrue(response.availablePackagesOnCDN.isEmpty)
	}

}
