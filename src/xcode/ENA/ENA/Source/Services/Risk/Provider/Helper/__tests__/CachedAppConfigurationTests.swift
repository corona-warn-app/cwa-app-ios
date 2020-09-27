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
		let client = CachingHTTPClientMock()

		let expectation = self.expectation(description: "app configuration loaded")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		expectation.expectedFulfillmentCount = 1
		expectation.assertForOverFulfill = true

		let expectedConfig = SAP_ApplicationConfiguration()
		client.onFetchAppConfiguration = { _, completeWith in
			let config = AppConfigurationFetchingResponse(expectedConfig, "etag")
			completeWith(.success(config))
			expectation.fulfill()
		}

		let store = MockTestStore()
		XCTAssertNil(store.appConfig)
		XCTAssertNil(store.lastETag)

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
		XCTAssertNotNil(store.lastETag)

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

		waitForExpectations(timeout: .long)
	}

	func testFetch_nothingCached() throws {

		let store = MockTestStore()
		XCTAssertNil(store.appConfig)
		XCTAssertNil(store.lastETag)

		let client = CachingHTTPClient()

		let expConfig = self.expectation(description: "app configuration fetched")

		let cache = CachedAppConfiguration(client: client, store: store)

		cache.appConfiguration { response in
			XCTAssertNotNil(store.appConfig)
			XCTAssertNotNil(store.lastETag)

			switch response {
			case .success(let config):
				XCTAssertTrue(config.isInitialized)
			case .failure(let error):
				XCTFail("Expected no error, got: \(error)")
			}
			expConfig.fulfill()
		}

		waitForExpectations(timeout: .long)
	}

	func testCacheNotModfied_useCache() throws {

		let expFetchRequest = self.expectation(description: "fetch request done")
		expFetchRequest.expectedFulfillmentCount = 1

		let store = MockTestStore()
		store.lastETag = "etag"
		store.appConfig = SAP_ApplicationConfiguration()

		let client = CachingHTTPClientMock()
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

		waitForExpectations(timeout: .long)
	}

	func testCacheNotModfied_nothingCached() throws {

		let expFetchRequest = self.expectation(description: "fetch request done")
		// 1. on init
		// 2. on `cache.appConfiguration` because of no config in store
		expFetchRequest.expectedFulfillmentCount = 2

		let store = MockTestStore()
		XCTAssertNil(store.appConfig)
		XCTAssertNil(store.lastETag)
		
		let client = CachingHTTPClientMock()
		client.onFetchAppConfiguration = { _, completeWith in
			XCTAssertNil(store.appConfig)
			XCTAssertNil(store.lastETag)

			completeWith(.failure(CachedAppConfiguration.CacheError.notModified))
			expFetchRequest.fulfill()
		}

		let expConfig = self.expectation(description: "app configuration fetched")

		let cache = CachedAppConfiguration(client: client, store: store)

		cache.appConfiguration { response in
			XCTAssertNil(store.appConfig)
			XCTAssertNil(store.lastETag)

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

		waitForExpectations(timeout: .long)
	}
}
