//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
import ZIPFoundation
@testable import ENA

class CacheAppConfigMockTests: XCTestCase {

	func testDefaultConfig() throws {
		let url = try XCTUnwrap(Bundle.main.url(forResource: "default_app_config_115", withExtension: ""))
		let data = try Data(contentsOf: url)
		let zip = try XCTUnwrap(Archive(data: data, accessMode: .read))
		let staticConfig = try zip.extractAppConfiguration()

		let onFetch = expectation(description: "config fetched")
		let subscription = CachedAppConfigurationMock().appConfiguration().sink { config in
			XCTAssertEqual(config, staticConfig)
			onFetch.fulfill()
		}

		waitForExpectations(timeout: .medium)

		subscription.cancel()
	}

	func testCustomConfig() throws {
		var customConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		customConfig.supportedCountries = ["foo", "bar", "baz"]

		let onFetch = expectation(description: "config fetched")
		let subscription = CachedAppConfigurationMock(with: customConfig).appConfiguration().sink { config in
			XCTAssertEqual(config, customConfig)
			XCTAssertEqual(config.supportedCountries, customConfig.supportedCountries)
			onFetch.fulfill()
		}

		waitForExpectations(timeout: .medium)

		subscription.cancel()
	}

	func testCacheSupportedCountries() throws {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]

		let gotValue = expectation(description: "got countries list")

		let subscription = CachedAppConfigurationMock(with: config)
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 6)
				gotValue.fulfill()
			}

		waitForExpectations(timeout: .medium)

		subscription.cancel()
	}

	func testCacheEmptySupportedCountries() throws {
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()

		let gotValue = expectation(description: "got countries list")
		let subscription = CachedAppConfigurationMock(with: config)
			.supportedCountries()
			.sink { countries in
				XCTAssertEqual(countries.count, 1)
				XCTAssertEqual(countries.first, .defaultCountry())
				gotValue.fulfill()
			}

		waitForExpectations(timeout: .medium)

		subscription.cancel()
	}
	
}
