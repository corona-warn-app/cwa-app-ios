//
// 🦠 Corona-Warn-App
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
