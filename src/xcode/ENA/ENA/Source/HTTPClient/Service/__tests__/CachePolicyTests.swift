//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CachePolicyTests: XCTestCase {

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
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, serverDate: nil, clientDate: Date())

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
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, serverDate: nil, clientDate: Date())

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
