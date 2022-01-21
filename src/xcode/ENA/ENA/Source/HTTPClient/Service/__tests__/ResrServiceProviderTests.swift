//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ResrServiceProviderTests: XCTestCase {

	func testGIVEN_CachedResource_WHEN_getSyncFromCache_THEN_ModelGetsReturned() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()
		let resource = ResourceFake(locator: locator)

		let dummyData = try makeDummyData("SomeData")
		let cachedDummyData = try makeDummyData("Goofy")

		// Cache with cachedDummyData
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// response with dummyData
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			],
			responseData: dummyData
		)

		// create a cache with cachedDummyData
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)

		// WHEN
		serviceProvider.cached(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}
			XCTAssertEqual(responseModel.dummyValue, "Goofy")
		}
	}

	// MARK: - Helpers

	func makeDummyData(_ value: String) throws -> Data {
		return try JSONEncoder().encode(
			DummyResourceModel(
				dummyValue: value
			)
		)
	}

}
