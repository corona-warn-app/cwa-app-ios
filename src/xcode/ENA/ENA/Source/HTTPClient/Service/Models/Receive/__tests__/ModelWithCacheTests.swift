//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ModelWithCacheTests: CWATestCase {
	
	func test_GIVEN_ModelWithCache_WHEN_RealModelIsFetchedFreshly_THEN_IsCachedIsFalse() {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		let cache = KeyValueCacheFake()
		let cachedRestService = CachedRestService(cache: cache)
		let resource = ResourceCachingCBORFake()
		
		// WHEN
		cachedRestService.load(resource) { result in
			switch result {
				
			case let .success(cachingModel):
				// THEN
				XCTAssertFalse(cachingModel.isCached)
			case let .failure(error):
				XCTFail("Test should success but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_GIVEN_ModelWithCache_WHEN_RealModelIsCached_THEN_IsCachedIsTrue() {
	
		// GIVEN
		
		// WHEN
		
		// THEN
		
		
	}
	
	func test_GIVEN_ModelWithCache_WHEN_NonCachingRestServiceIsUsed_THEN_IsCachedIsFalse() {
	
		// GIVEN
		
		// WHEN
		
		// THEN
		
		
	}
	
}

private struct TestCachingModel: CBORDecoding {
		
	private init(property: String ) {
		self.property = property
	}

	let property: String
	
	static func decode(_ data: Data) -> Result<TestCachingModel, ModelDecodingError> {
		return Result.success(TestCachingModel(property: "Decoded Value"))
	}
}

private class ResourceCachingCBORFake: Resource {
	
	init(
		locator: Locator = .fake(),
		receiveResource: CBORReceiveResource<ModelWithCache<TestCachingModel>> = CBORReceiveResource<ModelWithCache<TestCachingModel>>()
	) {
		self.locator = locator
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = receiveResource
	}
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ModelWithCache<TestCachingModel>>
	typealias CustomError = Error
	
	let locator: Locator
	let type: ServiceType
	let sendResource: EmptySendResource
	let receiveResource: CBORReceiveResource<ModelWithCache<TestCachingModel>>
}
