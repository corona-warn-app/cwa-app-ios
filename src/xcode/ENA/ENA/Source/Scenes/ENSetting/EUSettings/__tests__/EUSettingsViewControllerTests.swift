//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class EUSettingsViewControllerTests: XCTestCase {

	private var subscriptions: [AnyCancellable] = []

	func testDataReloadForSuccessfulDownload() {
		let exp = expectation(description: "config fetched")

		var customConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		customConfig.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]
		let configProvider = CachedAppConfigurationMock(with: customConfig)

		let vc = EUSettingsViewController(appConfigurationProvider: configProvider)
		vc.viewDidLoad()
		vc.appConfigurationProvider.appConfiguration().sink { config in
			XCTAssertEqual(config.supportedCountries.count, customConfig.supportedCountries.count)
			XCTAssertEqual(vc.tableView.numberOfRows(inSection: 1), config.supportedCountries.count)
			exp.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testDataForDefaultAppConfig() {
		let exp = expectation(description: "config fetched")

		let configProvider = CachedAppConfigurationMock()
		let vc = EUSettingsViewController(appConfigurationProvider: configProvider)
		vc.viewDidLoad()
		vc.appConfigurationProvider.appConfiguration().sink { config in
			// default config provides 0 countries but at least one cell is shown
			XCTAssertEqual(vc.tableView.numberOfRows(inSection: 1), max(config.supportedCountries.count, 1))
			exp.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}
}
