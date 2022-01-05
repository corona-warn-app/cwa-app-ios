//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

final class CachedAppConfigurationTests: CWATestCase {

	func testCachedRequests() {
		var subscriptions = Set<AnyCancellable>()

		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		fetchedFromClientExpectation.expectedFulfillmentCount = 1
		fetchedFromClientExpectation.assertForOverFulfill = true

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock()
		let expectedConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		let cache = CachedAppConfiguration(client: client, store: store)

		let completionExpectation = expectation(description: "app configuration completion called")
		completionExpectation.expectedFulfillmentCount = 2
		wait(for: [fetchedFromClientExpectation], timeout: .medium)

		cache.appConfiguration()
			.sink { config in
				XCTAssertEqual(config, expectedConfig)
				completionExpectation.fulfill()
			}
			.store(in: &subscriptions)

		XCTAssertNotNil(store.appConfigMetadata)

		// Should not trigger another call (expectation) to the actual client or a new risk calculation
		// Remember: `expectedFulfillmentCount = 1`
		cache.appConfiguration()
			.sink { config in
				XCTAssertEqual(config, expectedConfig)
				completionExpectation.fulfill()
			}
			.store(in: &subscriptions)

		wait(for: [completionExpectation], timeout: .medium)
	}

	func testCacheSupportedCountries() throws {
		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client")

		let store = MockTestStore()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]

		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		let gotValue = expectation(description: "got countries list")

		let cache = CachedAppConfiguration(client: client, store: store)
		wait(for: [fetchedFromClientExpectation], timeout: .medium)

		let subscription = cache
				.supportedCountries()
				.sink { countries in
					XCTAssertEqual(countries.count, 6)
					gotValue.fulfill()
				}

		wait(for: [gotValue], timeout: .medium)

		subscription.cancel()
	}

	func testCacheEmptySupportedCountries() throws {
		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client")

		let store = MockTestStore()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = []

		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		let gotValue = expectation(description: "got countries list")

		let cache = CachedAppConfiguration(client: client, store: store)
		wait(for: [fetchedFromClientExpectation], timeout: .medium)

		let subscription = cache
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 1)
				XCTAssertEqual(countries.first, .defaultCountry())
				gotValue.fulfill()
			}

		wait(for: [gotValue], timeout: .medium)

		subscription.cancel()
	}

	func testGIVEN_CachedAppConfigration_WHEN_FetchAppConfigIsCalledMultipleTimes_THEN_FetchIsCalledOnce() {
		// GIVEN
		let fetchedFromClientExpectation = expectation(description: "configuration fetched from client only once")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock()
		let expectedConfig = SAP_Internal_V2_ApplicationConfigurationIOS()

		client.onFetchAppConfiguration = { _, completeWith in
			sleep(2) // network
			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith((.success(config), nil))
			fetchedFromClientExpectation.fulfill()
		}

		// WHEN
		// Initialize the `CachedAppConfiguration` will trigger `fetchAppConfiguration`.
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)
		_ = CachedAppConfiguration(client: client, store: store)

		waitForExpectations(timeout: .medium)
		XCTAssertNotNil(store.appConfigMetadata)
	}

	func testMultipleRequestsForSupportedCountries() throws {
		let store = MockTestStore()
		var config = CachingHTTPClientMock.staticAppConfig
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]

		let httpRequest = expectation(description: "server request")
		let gotValue = expectation(description: "got countries list")
		gotValue.expectedFulfillmentCount = 3

		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			completeWith((.success(config), nil))
			httpRequest.fulfill()
		}

		var subscriptions = [AnyCancellable]()
		for _ in 0..<gotValue.expectedFulfillmentCount {
			let cache = CachedAppConfiguration(client: client, store: store)
			cache
				.supportedCountries()
				.sink { countries in
					XCTAssertEqual(countries.count, 6)
					gotValue.fulfill()
				}
				.store(in: &subscriptions)
		}

		waitForExpectations(timeout: .medium)
	}

	func test_stressTestAppConfigurationAccess() {
		let store = MockTestStore()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()

		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(config, "etag")
			let clientQueue = DispatchQueue(label: "ClientQueue", attributes: .concurrent)
			
			// Dispatch the completion call to simulate URLSession calling back on another thread.
			clientQueue.async {
				usleep(100_000) // 0.1s
				completeWith((.success(config), nil))
			}
		}

		let cache = CachedAppConfiguration(client: client, store: store)
		let callbackExpectations = expectation(description: "AppConfigurationCallback")
		callbackExpectations.expectedFulfillmentCount = 1001
		
		var stressTestSubscriptions = [AnyCancellable]()
		let concurrentQueue = DispatchQueue(label: "AppConfigurationAccessQueue", attributes: .concurrent)
		let subscriptionQueue = DispatchQueue(label: "SubscriptionQueue")
		
		for _ in 0...1000 {
			// Stress the CachedAppConfiguration with a lot a concurrent calls.
			concurrentQueue.async {
				usleep(10_000) // 0.01s

				let subscription = cache.appConfiguration(forceFetch: true).sink { _ in
					callbackExpectations.fulfill()
				}
				
				// Because we are in a concurrent call, we need to serial sync the access to the subsciptions queue to avoid data inconsistencies.
				subscriptionQueue.sync {
					stressTestSubscriptions.append(subscription)
				}
			}
		}
		
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
