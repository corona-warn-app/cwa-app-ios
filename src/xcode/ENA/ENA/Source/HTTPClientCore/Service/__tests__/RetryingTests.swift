//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class RetryingTests: XCTestCase {

	func testGIVEN_RetryingResource_WHEN_load_THEN_RetryCalledCount() throws {

		let loadExpectation = expectation(description: "Retrying is done.")
		let defaultDummyModel = DummyResourceModel(
			dummyValue: "Minnie"
		)

		let defaultDummyData = try JSONEncoder().encode( defaultDummyModel )
		let locator: Locator = .fake()

		// Return nil and http code 500. In this case the service would ignore caching behavior and look up for default values.
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: nil
		)

		let standardService = StandardRestService(session: stack.urlSession)

		let resource = ResourceFake(retryingCount: 3)

		standardService.load(resource, { result in

			switch result {

			case .success(_):
				<#code#>
			case .failure(_):
				<#code#>
			}
			loadExpectation.fulfill()
		})

		waitForExpectations(timeout: .short)

	}
}
