////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTraceWarningPackageDownloadTests: CWATestCase {

	/*
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
				// THEN
				if case let .receivedResourceError(traceWarningError) = error,
				   traceWarningError == .generalError {
					XCTAssertTrue(true)
				} else {
					XCTFail("unexpected error case")
				}
			}
		}
		waitForExpectations(timeout: .short)
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
	 */
}
