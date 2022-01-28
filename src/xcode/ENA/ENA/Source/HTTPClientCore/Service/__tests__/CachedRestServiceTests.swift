//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CachedRestServiceTests: XCTestCase {

	func test_ResponseIsStoredInCache() throws {
		let dummyData = try JSONEncoder().encode(
			DummyResourceModel(
				dummyValue: "SomeValue"
			)
		)
		let locator: Locator = .fake()
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": "SomeValue"
			],
			responseData: dummyData
		)

		let cache = KeyValueCacheFake()

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(locator: locator)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { _ in
			// Check if the value stored in the cache is the same like the one returned from the http session.
			do {
				let cachedData = try XCTUnwrap(cache[locator.hashValue])
				XCTAssertEqual(cachedData.data, dummyData)
				loadExpectation.fulfill()
			} catch {
				XCTFail("Test failed with error: \(error)")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func test_CachedValueIsLoaded() throws {
		let eTag = "DummyDataETag"
		let dummyModel = DummyResourceModel(
			dummyValue: "SomeValue"
		)
		let dummyData = try JSONEncoder().encode( dummyModel )
		let locator: Locator = .fake()

		// Store the dummy data in the cache.
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: dummyData, eTag: eTag, date: Date())

		// Return nil and http code 304. In this case the service should load the result from the cache.
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: [
				"ETag": eTag
			],
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(locator: locator)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			// Check if the value returned is the same like the one stored in the cache before.

			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, dummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_DefaultValueIsLoaded() throws {
		let dummyModel = DummyResourceModel(
			dummyValue: "SomeValue"
		)
		let cache = KeyValueCacheFake()

		// Return nil and http code 304. In this case the service should load the reault from the cache.
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(defaultModel: dummyModel)
		let loadExpectation = expectation(description: "Default value should be returned.")

		cachedService.load(resource) { result in
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
	
	func test_CachedValueIsLoadedButDefaultValueNot() throws {
		let eTag = "DummyDataETag"
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "Goofy"
		)
		let defaultDummyModel = DummyResourceModel(
			dummyValue: "Pluto"
		)
		
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let locator: Locator = .fake()

		// Store the dummy data in the cache.
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// Return nil and http code 304. In this case the service should load the caching value from the cache.
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: [
				"ETag": eTag
			],
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(locator: locator, defaultModel: defaultDummyModel)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			// Check if the value returned is the same like the one stored in the cache before.

			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, cachedDummyModel)
			XCTAssertNotEqual(responseModel, defaultDummyModel)

			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_DefaultValueIsLoadedButCachedValueNot() throws {
		let eTag = "DummyDataETag"
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "Donald"
		)
		let defaultDummyModel = DummyResourceModel(
			dummyValue: "Minnie"
		)
		
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let locator: Locator = .fake()

		// Store the dummy data in the cache.
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		// Return nil and http code 500. In this case the service would ignore caching behavior and look up for default values.
		let stack = MockNetworkStack(
			httpStatus: 500,
			headerFields: [
				"ETag": eTag
			],
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(locator: locator, defaultModel: defaultDummyModel)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			// Check if the value returned is the same like the one defined before.

			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertNotEqual(responseModel, cachedDummyModel)
			XCTAssertEqual(responseModel, defaultDummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	// MARK: - Cache Policy tests
	
	func test_GIVEN_CachePolicyNoNetwork_WHEN_DefaultValueNoCacheIsSet_THEN_DefaultValueIsReturned() {
		let cache = KeyValueCacheFake()

		let stack = MockNetworkStack(
			httpStatus: 304,
			responseData: nil,
			error: FakeError.fake
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)
		
		let defaultDummyModel = DummyResourceModel(
			dummyValue: "Stark"
		)

		let resource = ResourceFake(
			type: .caching([.noNetwork]),
			defaultModel: defaultDummyModel
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			// Check if the value returned is the same like the one stored in the cache before.
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, defaultDummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachePolicyNoNetwork_WHEN_NoDefaultValueButCacheIsSet_THEN_CacheIsReturned() throws {
		let eTag = "DummyDataETag"
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "Targaryien"
		)
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let locator: Locator = .fake()

		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		let stack = MockNetworkStack(
			httpStatus: 500,
			headerFields: [
				"ETag": eTag
			],
			responseData: nil,
			error: FakeError.fake
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching([.noNetwork])
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, cachedDummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachePolicyNoNetwork_WHEN_NoDefaultValueNoCacheIsSet_THEN_OriginalErrorIsReturned() {
		let cache = KeyValueCacheFake()
		
		let fakeError = FakeError.fake

		let stack = MockNetworkStack(
			httpStatus: 987,
			responseData: nil,
			error: fakeError
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching([.noNetwork])
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .failure(responseError) = result else {
				XCTFail("Error expected")
				return
			}

			XCTAssertEqual(responseError, .transportationError(fakeError))
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachingWithoutPolicyWithError_WHEN_NoDefaultValueNoCacheIsSet_THEN_OriginalErrorIsReturned() {
		let cache = KeyValueCacheFake()
		
		let fakeError = FakeError.fake

		let stack = MockNetworkStack(
			httpStatus: 987,
			responseData: nil,
			error: fakeError
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching()
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .failure(responseError) = result else {
				XCTFail("Error expected")
				return
			}

			XCTAssertEqual(responseError, .transportationError(fakeError))
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachePolicyStatusCode404_WHEN_DefaultValueNoCacheIsSet_THEN_DefaultValueIsReturned() {
		let cache = KeyValueCacheFake()

		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)
		
		let defaultDummyModel = DummyResourceModel(
			dummyValue: "Stark"
		)

		let resource = ResourceFake(
			type: .caching([.statusCode(404)]),
			defaultModel: defaultDummyModel
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			// Check if the value returned is the same like the one stored in the cache before.
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, defaultDummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachePolicyStatusCode404_WHEN_NoDefaultValueButCacheIsSet_THEN_CacheIsReturned() throws {
		let eTag = "DummyDataETag"
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "Targaryien"
		)
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let locator: Locator = .fake()

		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, date: Date())

		let stack = MockNetworkStack(
			httpStatus: 404,
			headerFields: [
				"ETag": eTag
			],
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching([.statusCode(404)])
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel, cachedDummyModel)
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachePolicyStatusCode987_WHEN_NoDefaultNoCacheValueIsSet_THEN_OriginalErrorIsReturned() {
		let cache = KeyValueCacheFake()
		

		let stack = MockNetworkStack(
			httpStatus: 987,
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching([.noNetwork])
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .failure(responseError) = result else {
				XCTFail("Error expected")
				return
			}

			XCTAssertEqual(responseError, .unexpectedServerError(987))
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_CachingWithoutPolicyWithoutError_WHEN_NoDefaultValueNoCacheIsSet_THEN_OriginalErrorIsReturned() {
		let cache = KeyValueCacheFake()
		
		let stack = MockNetworkStack(
			httpStatus: 987,
			responseData: nil
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching()
		)
		let loadExpectation = expectation(description: "Load completion should be called.")

		cachedService.load(resource) { result in
			guard case let .failure(responseError) = result else {
				XCTFail("Error expected")
				return
			}

			XCTAssertEqual(responseError, .unexpectedServerError(987))
			loadExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}
}
