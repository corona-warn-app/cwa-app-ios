////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDiscoveryTests: CWATestCase {

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
		let expectedResponse = TraceWarningDiscoveryModel(oldest: oldest, latest: latest)
		
		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDiscoveryResource(unencrypted: true, country: "DE")
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(traceWarningDiscovery):
				XCTAssertEqual(traceWarningDiscovery.oldest, expectedResponse.oldest)
				XCTAssertEqual(traceWarningDiscovery.latest, expectedResponse.latest)
				XCTAssertEqual(traceWarningDiscovery.availablePackagesOnCDN, expectedResponse.availablePackagesOnCDN)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Country_WHEN_ResponseIsMissing_THEN_DefaultServerErrorIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDiscoveryResource(unencrypted: true, country: "DE")
		restService.load(resource) { result in
		// WHEN
			defer { expectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Test should not succeed")
			case let .failure(error):
				guard case let .receivedResourceError(receivedResourceError) = error,
					  case .invalidResponseError = receivedResourceError else {
					XCTFail("Wrong error: \(error)")
					return
				}
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
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
		let expectedResponse = TraceWarningDiscoveryModel(oldest: oldest, latest: latest)
		
		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDiscoveryResource(unencrypted: true, country: "DE")
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(traceWarningDiscovery):
				XCTAssertEqual(traceWarningDiscovery.oldest, expectedResponse.oldest)
				XCTAssertEqual(traceWarningDiscovery.latest, expectedResponse.latest)
				XCTAssertEqual(traceWarningDiscovery.availablePackagesOnCDN, expectedResponse.availablePackagesOnCDN)
				XCTAssertEqual(traceWarningDiscovery.availablePackagesOnCDN.count, 1)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

/*
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
		var expectedResponse: TraceWarningDiscoveryModel?
		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(unencrypted: true, country: "DE", completion: { result in
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
*/
}
