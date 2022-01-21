//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ResrServiceProviderTests: XCTestCase {

	func testGIVEN_CacheWithResourceData_WHEN_getCachedModel_THEN_ModelGetsReturned() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()
		let resource = ResourceFake(locator: locator)
		let cachedDummyData = try makeDummyData("Goofy")

		// Cache with cachedDummyData
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// response with dummyData
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			]
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

	func testGIVEN_CacheWithResourceData_WHEN_getCachedModelButServiceTypeIsWrong_THEN_MissingCache() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()
		let resource = ResourceFake(locator: locator, type: .default)
		let cachedDummyData = try makeDummyData("Goofy")

		// Cache with cachedDummyData
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// response with dummyData
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			]
		)

		// create a cache with cachedDummyData
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)

		// WHEN missingCache error is given
		serviceProvider.cached(resource) { result in
			guard case let .failure(serviceError) = result,
				  case let .resourceError(resourceError) = serviceError,
				  case .missingCache = resourceError else {
					  XCTFail("failure expected")
					  return
				  }
		}
	}

	func testGIVEN_CacheWithoutResourceData_WHEN_getCachedModelButServiceTypeIsWrong_THEN_MissingCache() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()
		let resource = ResourceFake(locator: locator)

		// Cache with cachedDummyData
		let cache = KeyValueCacheFake()

		// response with dummyData
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			]
		)

		// create a cache with cachedDummyData
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)

		// WHEN missingCache error is given
		serviceProvider.cached(resource) { result in
			guard case let .failure(serviceError) = result,
				  case let .resourceError(resourceError) = serviceError,
				  case .missingCache = resourceError else {
					  XCTFail("failure expected")
					  return
				  }
		}
	}

	func testGIVEN_CacheWithResourceData_WHEN_getCachedButLocatorIsDifferent_THEN_MissingCache() throws {
		// GIVEN
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()
		let resource = ResourceFake(locator: .fake(paths: ["other", "path"]))
		let cachedDummyData = try makeDummyData("Goofy")

		// Cache with cachedDummyData
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// response with dummyData
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			]
		)

		// create a cache with cachedDummyData
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)

		// WHEN missingCache error is given
		serviceProvider.cached(resource) { result in
			guard case let .failure(serviceError) = result,
				  case let .resourceError(resourceError) = serviceError,
				  case .missingCache = resourceError else {
					  XCTFail("failure expected")
					  return
				  }
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
