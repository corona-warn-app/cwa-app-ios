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
import Combine
@testable import ENA

class EUSettingsViewControllerTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	func testDataReloadForSuccessfulDownload() {
		let exp = expectation(description: "config fetched")

		var customConfig = SAP_Internal_ApplicationConfiguration()
		customConfig.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]
		let configProvider = CachedAppConfigurationMock(with: customConfig)

		let vc = EUSettingsViewController(appConfigurationProvider: configProvider)
		vc.viewDidLoad()
		vc.appConfigurationProvider.appConfiguration().sink { config in
			XCTAssertEqual(config.supportedCountries.count, customConfig.supportedCountries.count)
			XCTAssertEqual(vc.tableView.numberOfRows(inSection: 1), config.supportedCountries.count)
			exp.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
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

		waitForExpectations(timeout: .short)
	}
}
