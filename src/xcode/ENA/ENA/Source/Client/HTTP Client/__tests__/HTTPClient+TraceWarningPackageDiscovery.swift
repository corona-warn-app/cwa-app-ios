////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDiscovery: XCTestCase {

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
		let expectedResponse = TraceWarningDiscovery(oldest: oldest, latest: latest, availablePackagesOnCDN: Array(oldest...latest), eTag: "FakeETag")
		
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
	
	func testGIVEN_Country_WHEN_MissingParamsInResponse_THEN_DecodingJsonErrorIsReturned() throws {

		// GIVEN
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: nil, latest: nil))
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
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
		XCTAssertEqual(responseError, TraceWarningError.decodingJsonError(200))
	}
	
	func testGIVEN_Country_WHEN_WrongStatusCode400_THEN_InvalidResponseErrorIsReturned() throws {

		// GIVEN
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(TraceWarningDiscoveryResponse(oldest: nil, latest: nil))
		
		let stack = MockNetworkStack(
			httpStatus: 401,
			responseData: encoded
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
		XCTAssertEqual(responseError, TraceWarningError.invalidResponseError(401))
	}
}
