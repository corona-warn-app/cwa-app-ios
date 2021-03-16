////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDownload: XCTestCase {

	let expectationsTimeout: TimeInterval = 2

	func testGIVEN_Country_WHEN_HappyCase_THEN_TraceWarningPackageIsReturned() throws {

//		// GIVEN
//		let packageId = 448520
//		let jsonEncoder = JSONEncoder()
//		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: oldest, latest: latest))

//		let stack = MockNetworkStack(
//			httpStatus: 200,
//			responseData: encoded
//		)
//		let expectation = self.expectation(description: "completion handler is called without an error")
//		let expectedResponse = TraceWarningDiscovery(oldest: oldest, latest: latest, availablePackagesOnCDN: Array(oldest...latest), eTag: "FakeETag")

//		// WHEN
//		var response: TraceWarningDiscovery?
//		HTTPClient.makeWith(mock: stack).traceWarningPackageDiscovery(country: "DE", completion: { result in
//			switch result {
//			case let .success(traceWarningDiscovery):
//				response = traceWarningDiscovery
//				expectation.fulfill()
//			case let .failure(error):
//				XCTFail("Test should not fail with error: \(error)")
//			}
//		})
//
//		// THEN
//		waitForExpectations(timeout: .short)
//		XCTAssertNotNil(response)
//		XCTAssertEqual(response?.oldest, expectedResponse.oldest)
//		XCTAssertEqual(response?.latest, expectedResponse.latest)
//		XCTAssertEqual(response?.availablePackagesOnCDN, expectedResponse.availablePackagesOnCDN)
	}

}
