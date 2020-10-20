//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
@testable import ENA

final class CachedAppConfigurationTests: XCTestCase {
	func testCachedRequests() {

		let expectation = self.expectation(description: "app configuration loaded")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		expectation.expectedFulfillmentCount = 1
		expectation.assertForOverFulfill = true

		let store = MockTestStore()
		XCTAssertNil(store.appConfig)
		XCTAssertNil(store.lastAppConfigETag)

		let client = CachingHTTPClientMock(store: store)
		let expectedConfig = SAP_ApplicationConfiguration()
		client.onFetchAppConfiguration = { _, completeWith in
			store.lastAppConfigFetch = Date()

			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith(.success(config))
			expectation.fulfill()
		}

		let expConfig = self.expectation(description: "app configuration fetched")
		expConfig.expectedFulfillmentCount = 2

		let cache = CachedAppConfiguration(client: client, store: store)
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, expectedConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expConfig.fulfill()
		}

		XCTAssertNotNil(store.appConfig)
		XCTAssertNotNil(store.lastAppConfigETag)

		// Should not trigger another call (expectation) to the actual client
		// Remember: `expectedFulfillmentCount = 1`
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, expectedConfig)
				XCTAssertEqual(config, store.appConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}

	func testCacheDecay() throws {
		let outdatedConfig = SAP_ApplicationConfiguration()
		let updatedConfig = CachingHTTPClientMock.staticAppConfig

		let store = MockTestStore()
		store.appConfig = outdatedConfig
		store.lastAppConfigFetch = 297.secondsAgo // close to the assumed 300 seconds default decay

		let client = CachingHTTPClientMock(store: store)

		let lastFetch = try XCTUnwrap(store.lastAppConfigFetch)
		XCTAssertLessThan(Date().timeIntervalSince(lastFetch), 300)

		let expectation = self.expectation(description: "app configuration loaded")
		expectation.assertForOverFulfill = true

		client.onFetchAppConfiguration = { _, completeWith in
			store.appConfig = updatedConfig
			store.lastAppConfigFetch = Date()

			let config = AppConfigurationFetchingResponse(updatedConfig, "etag")
			completeWith(.success(config))
			expectation.fulfill()
		}

		let expConfig = self.expectation(description: "app configuration fetched")
		expConfig.expectedFulfillmentCount = 2

		let cache = CachedAppConfiguration(client: client, store: store)
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, outdatedConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expConfig.fulfill()
		}

		XCTAssertEqual(store.appConfig, outdatedConfig)

		// ensure cache decay
		sleep(5)
		XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(lastFetch), 300)

		// second fetch – expected decayed cached and updated config
		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, updatedConfig)
				XCTAssertEqual(config, store.appConfig)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: 10)
	}

	func testFetch_nothingCached() throws {

		let store = MockTestStore()
		store.appConfig = nil
		store.lastAppConfigETag = nil

		let client = CachingHTTPClientMock(store: store)

		let expConfig = self.expectation(description: "app configuration fetched")

		let cache = CachedAppConfiguration(client: client, store: store)

		cache.appConfiguration { response in
			XCTAssertNotNil(store.appConfig)
			XCTAssertNotNil(store.lastAppConfigETag)

			switch response {
			case .success(let config):
				XCTAssertTrue(config.isInitialized)
			case .failure(let error):
				XCTFail("Expected no error, got: \(error)")
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}

	func testCacheNotModfied_useCache() throws {

		let expFetchRequest = self.expectation(description: "fetch request done")
		expFetchRequest.expectedFulfillmentCount = 1

		let store = MockTestStore()
		store.lastAppConfigETag = "etag"
		store.appConfig = SAP_ApplicationConfiguration()

		let client = CachingHTTPClientMock(store: store)
		client.onFetchAppConfiguration = { _, completeWith in
			completeWith(.failure(CachedAppConfiguration.CacheError.notModified))
			expFetchRequest.fulfill()
		}

		let expConfig = self.expectation(description: "app configuration fetched")

		let cache = CachedAppConfiguration(client: client, store: store)

		cache.appConfiguration { response in
			switch response {
			case .success(let config):
				XCTAssertEqual(config, store.appConfig)
			case .failure(let error):
				XCTFail("Expected no error, got: \(error)")
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}

	func testCacheNotModfied_nothingCached() throws {

		let expFetchRequest = self.expectation(description: "fetch request done")
		// 1. on init
		// 2. on `cache.appConfiguration` because of no config in store
		expFetchRequest.expectedFulfillmentCount = 2

		let store = MockTestStore()
		XCTAssertNil(store.appConfig)
		XCTAssertNil(store.lastAppConfigETag)
		
		let client = CachingHTTPClientMock(store: store)
		client.onFetchAppConfiguration = { _, completeWith in
			XCTAssertNil(store.appConfig)
			XCTAssertNil(store.lastAppConfigETag)

			completeWith(.failure(CachedAppConfiguration.CacheError.notModified))
			expFetchRequest.fulfill()
		}

		let expConfig = self.expectation(description: "app configuration fetched")

		let cache = CachedAppConfiguration(client: client, store: store)

		cache.appConfiguration { response in
			XCTAssertNil(store.appConfig)
			XCTAssertNil(store.lastAppConfigETag)

			switch response {
			case .success:
				XCTFail("expected to fail")
			case .failure(let error):
				let err = error as? CachedAppConfiguration.CacheError
				if case .notModified = err {
					XCTAssert(true)
					// we exprect the .notModified error
					// Tip: you should remove the `lastETag` from the store in this case
				} else {
					XCTFail("wrong error type; got: \(error)")
				}
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}
}

private extension Int {

	/// A date n seconds ago
	var secondsAgo: Date? {
		let components = DateComponents(second: -(self))
		return Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
	}
}
