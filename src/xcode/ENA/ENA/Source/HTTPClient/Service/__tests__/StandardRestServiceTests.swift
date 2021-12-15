//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA


class StandardRestServiceTests: XCTestCase {
	
	func test_DefaultValueIsLoaded() throws {
		let dummyModel = DummyResourceModel(
			dummyValue: "Mickey Maus"
		)
		
		// Return nil and http code 304. In this case the service should load the reault from the cache.
		let stack = MockNetworkStack(
			httpStatus: 503,
			responseData: nil
		)
		
		let standardService = StandardRestService(
			session: stack.urlSession
		)
		
		let resource = ResourceFake(defaultModel: dummyModel)
		let loadExpectation = expectation(description: "Default value should be returned.")
		
		standardService.load(resource) { result in
			// Check if the value returned is the same like the default one.
			
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}
			
			XCTAssertEqual(responseModel, dummyModel)
			loadExpectation.fulfill()
		}
		
		waitForExpectations(timeout: .short)
	}
}
