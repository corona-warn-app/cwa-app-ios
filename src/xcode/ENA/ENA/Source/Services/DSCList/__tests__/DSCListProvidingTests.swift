////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DSCListProvidingTests: XCTestCase {

	func testGIVEN_client_WHEN_fetch_THEN_success() {
		// GIVEN
		let fetchedFromClientExpectation = expectation(description: "DSC list fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1
		let client = CachingHTTPClientMock()

		// WHEN
		client.fetchDSCList(etag: "fake") { result in
			switch result {
			case .success(let response):
				XCTAssertNotNil(response.eTag)
				XCTAssertNotNil(response.dscList)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

}
