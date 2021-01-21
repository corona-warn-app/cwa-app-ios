//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

final class CachedAppConfigurationTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	func testCachedRequests() {

		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		fetchedFromClientExpectation.expectedFulfillmentCount = 1
		fetchedFromClientExpectation.assertForOverFulfill = true

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock(store: store)
		let expectedConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		let cache = CachedAppConfiguration(client: client, store: store)

		let completionExpectation = expectation(description: "app configuration completion called")
		completionExpectation.expectedFulfillmentCount = 2

		cache.appConfiguration().sink { config in
			XCTAssertEqual(config, expectedConfig)
			completionExpectation.fulfill()
		}.store(in: &subscriptions)

		XCTAssertNotNil(store.appConfigMetadata)

		// Should not trigger another call (expectation) to the actual client or a new risk calculation
		// Remember: `expectedFulfillmentCount = 1`
		cache.appConfiguration().sink { config in
			XCTAssertEqual(config, expectedConfig)
			completionExpectation.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testCacheSupportedCountries() throws {
		let store = MockTestStore()
		var config = CachingHTTPClientMock.staticAppConfig
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]

		let client = CachingHTTPClientMock(store: store)
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			completeWith((.success(config), nil))
		}

		let gotValue = expectation(description: "got countries list")

		let cache = CachedAppConfiguration(client: client, store: store)
		cache
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 6)
				gotValue.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testCacheEmptySupportedCountries() throws {
		let store = MockTestStore()
		var config = CachingHTTPClientMock.staticAppConfig
		config.supportedCountries = []

		let gotValue = expectation(description: "got countries list")
		gotValue.expectedFulfillmentCount = 2

		let client = CachingHTTPClientMock(store: store)
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			completeWith((.success(config), nil))
			gotValue.fulfill()
		}

		let cache = CachedAppConfiguration(client: client, store: store)
		cache
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 1)
				XCTAssertEqual(countries.first, .defaultCountry())
				gotValue.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-3781
	func testGIVEN_CachedAppConfigration_WHEN_FetchAppConfigIsCalledMultipleTimes_THEN_FetchIsCalledOnce() {
		// GIVEN
		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client only once")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock(store: store)
		let expectedConfig = SAP_Internal_V2_ApplicationConfigurationIOS()

		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		// WHEN
		// Initilize the `CachedAppConfiguration` will trigger `fetchAppConfiguration`.
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)

		XCTAssertNotNil(store.appConfigMetadata)
		XCTAssertEqual(fetchedFromClientExpectation.expectedFulfillmentCount, 1)
		waitForExpectations(timeout: .medium)
	}
}

extension Int {

	/// A date n seconds ago
	var secondsAgo: Date? {
		let components = DateComponents(second: -(self))
		return Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
	}

}
