////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientGetDccRulesTests: CWATestCase {
	
	func testGIVEN_Client_WHEN_HappyPath_THEN_PackageIsReturned() throws {
					
		// GIVEN
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-rule", withExtension: nil)
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["eTag": "\"SomeEtag\""],
			responseData: try Data(contentsOf: XCTUnwrap(url))
		)
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		// WHEN
		var response: PackageDownloadResponse?
		let client = HTTPClient.makeWith(mock: stack)
		client.getRules(ruleType: .acceptance, completion: { result in
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
