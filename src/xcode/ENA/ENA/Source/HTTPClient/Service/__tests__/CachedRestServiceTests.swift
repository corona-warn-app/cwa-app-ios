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

		let resource = ResourceFake()
		resource.locator = locator
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

	func test_ResonseIsLoadedFromCache() throws {
		let eTag = "DummyDataETag"
		let dummyModel = DummyResourceModel(
			dummyValue: "SomeValue"
		)
		let dummyData = try JSONEncoder().encode( dummyModel )
		let locator: Locator = .fake()

		// Store the dummy data in the cache.
		let cache = KeyValueCacheFake()
		cache[locator.hashValue] = CacheData(data: dummyData, eTag: eTag, date: Date())

		// Return nil and http code 304. In this case the service should load the reault from the cache.
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

		let resource = ResourceFake()
		resource.locator = locator
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

		let resource = ResourceFake(defaultValue: dummyModel)
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
}

struct DummyResourceModel: PaddingResource, Codable, Equatable {
	var dummyValue: String
	var requestPadding: String = ""
}

class ResourceFake: Resource {
	
	init(
		defaultValue: Receive.ReceiveModel? = nil
	) {
		self.defaultModel = defaultValue
	}
	var locator: Locator = .fake()
	var type: ServiceType = .caching([])
	var sendResource = PaddingJSONSendResource<DummyResourceModel>(DummyResourceModel(dummyValue: "SomeValue", requestPadding: ""))
	var receiveResource = JSONReceiveResource<DummyResourceModel>()
	var defaultModel: Receive.ReceiveModel?

	typealias Send = PaddingJSONSendResource<DummyResourceModel>
	typealias Receive = JSONReceiveResource<DummyResourceModel>
	typealias CustomError = Error

}
