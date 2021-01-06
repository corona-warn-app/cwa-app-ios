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
import OpenCombine
import ZIPFoundation
@testable import ENA

class CacheAppConfigMockTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	func testDefaultConfig() throws {
		let url = try XCTUnwrap(Bundle.main.url(forResource: "default_app_config_18", withExtension: ""))
		let data = try Data(contentsOf: url)
		let zip = try XCTUnwrap(Archive(data: data, accessMode: .read))
		let staticConfig = try zip.extractAppConfiguration()

		let onFetch = expectation(description: "config fetched")
		CachedAppConfigurationMock().appConfiguration().sink { config in
			XCTAssertEqual(config, staticConfig)
			onFetch.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testCustomConfig() throws {
		var customConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		customConfig.supportedCountries = ["foo", "bar", "baz"]

		let onFetch = expectation(description: "config fetched")
		CachedAppConfigurationMock(with: customConfig).appConfiguration().sink { config in
			XCTAssertEqual(config, customConfig)
			XCTAssertEqual(config.supportedCountries, customConfig.supportedCountries)
			onFetch.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testCacheSupportedCountries() throws {
		var config = CachingHTTPClientMock.staticAppConfig
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]

		let gotValue = expectation(description: "got countries list")

		CachedAppConfigurationMock(with: config)
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 6)
				gotValue.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
	}

	func testCacheEmptySupportedCountries() throws {
		let gotValue = expectation(description: "got countries list")

		CachedAppConfigurationMock(with: CachingHTTPClientMock.staticAppConfig)
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 1)
				XCTAssertEqual(countries.first, .defaultCountry())
				gotValue.fulfill()
			}
			.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
	}
}
