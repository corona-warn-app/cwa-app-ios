//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CachePolicyTests: XCTestCase {

	// MARK: Helpers

	let today = Date()

	func date(day delta: Int) -> Date? {
		var component = DateComponents()
		component.day = delta
		return Calendar.current.date(byAdding: component, to: today)
	}

	func date(hours delta: Int, fromDate: Date? = nil) -> Date? {
		var component = DateComponents()
		component.hour = delta

		let date = fromDate ?? today
		return Calendar.current.date(byAdding: component, to: date)
	}

	var midnight: Date? {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: today, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .backward)
	}

	// MARK: Caching policy loadOnlyOnceADay

	func testGIVEN_policyLoadOnlyOnceADay_WHEN_cacheDateIsWithinSameDay_THEN_ResultIsCachedModel() throws {
		// GIVEN
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "old data"
		)
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()

		// midnight is oldest possible date within the same day
		let midnightDate = try XCTUnwrap(midnight)
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, serverDate: nil, clientDate: midnightDate)

		let newResponseData = try JSONEncoder().encode(
			DummyResourceModel(
				dummyValue: "new data"
			)
		)

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			],
			responseData: newResponseData
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache
		)

		let resource = ResourceFake(
			type: .caching([.loadOnlyOnceADay])
		)

		let loadExpectation = expectation(description: "Load completion should be called.")

		// WHEN
		cachedService.load(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel.dummyValue, "old data")
			loadExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_policyLoadOnlyOnceADay_WHEN_cacheDateIsOlderThenSameDay_THEN_ResultIsReceivedModel() throws {
		// GIVEN
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "old data"
		)
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()

		let beforeMidnightDate = try XCTUnwrap(date(hours: -4, fromDate: midnight))
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, serverDate: nil, clientDate: beforeMidnightDate)

		let newResponseData = try JSONEncoder().encode(
			DummyResourceModel(
				dummyValue: "new data"
			)
		)

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": eTag
			],
			responseData: newResponseData
		)

		let cachedService = CachedRestService(
			session: stack.urlSession,
			cache: cache,
			fakeClientCacheDate: today
		)

		let resource = ResourceFake(
			type: .caching([.loadOnlyOnceADay])
		)

		let loadExpectation = expectation(description: "Load completion should be called.")

		// WHEN
		cachedService.load(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel.dummyValue, "new data")
			loadExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		let cachedData = try XCTUnwrap(cache[locator.hashValue])
		XCTAssertEqual(cachedData.clientDate, today)
	}

	func testGIVEN_policyLoadOnlyOnceADay_WHEN_cacheDateIsOlderThenSameDay_THEN_NotModifiedResultIsCachedModel() throws {
		// GIVEN
		let cachedDummyModel = DummyResourceModel(
			dummyValue: "old data"
		)
		let cachedDummyData = try JSONEncoder().encode( cachedDummyModel )
		let eTag = "DummyDataETag"
		let locator: Locator = .fake()

		let beforeMidnightDate = try XCTUnwrap(date(hours: -4, fromDate: midnight))
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: cachedDummyData, eTag: eTag, serverDate: nil, clientDate: beforeMidnightDate)

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

		let resource = ResourceFake(
			type: .caching([.loadOnlyOnceADay])
		)

		let loadExpectation = expectation(description: "Load completion should be called.")
		// WHEN

		cachedService.load(resource) { result in
			guard case let .success(responseModel) = result else {
				XCTFail("Success expected")
				return
			}

			XCTAssertEqual(responseModel.dummyValue, "old data")
			loadExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	// MARK: - previous existing tests

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
