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

	func testGIVEN_Country_WHEN_OldestIsNil_THEN_EmptyAvailablePackagesOnCDNAreReturned() throws {
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
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDiscoveryResource(unencrypted: true, country: "DE")
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(traceWarningDiscovery):
				// If oldest or latest are nil, we expect for oldest 0 and latest -1.
				XCTAssertEqual(traceWarningDiscovery.oldest, 0)
				XCTAssertEqual(traceWarningDiscovery.latest, -1)
				XCTAssertTrue(traceWarningDiscovery.availablePackagesOnCDN.isEmpty)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_Country_WHEN_LatestIsNil_THEN_EmptyAvailablePackagesOnCDNAreReturned() throws {
		// GIVEN
		let jsonEncoder = JSONEncoder()
		// At least, one of the two must be nil to trigger an empty package response
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: 3214, latest: nil))

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = TraceWarningDiscoveryResource(unencrypted: true, country: "DE")
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case let .success(traceWarningDiscovery):
				// If oldest or latest are nil, we expect for oldest 0 and latest -1.
				XCTAssertEqual(traceWarningDiscovery.oldest, 0)
				XCTAssertEqual(traceWarningDiscovery.latest, -1)
				XCTAssertTrue(traceWarningDiscovery.availablePackagesOnCDN.isEmpty)
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

}
