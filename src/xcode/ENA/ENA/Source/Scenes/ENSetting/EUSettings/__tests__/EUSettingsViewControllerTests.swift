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

class EUSettingsViewControllerTests: XCTestCase {

	func testDataReloadForSuccessfulDownload() {
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]
		let fakeResult: (Result<SAP_Internal_V2_ApplicationConfigurationIOS, Error>) = .success(config)
		let appConfigurationProviderStub = AppConfigurationProviderStub(result: fakeResult)

		let vc = EUSettingsViewController(appConfigurationProvider: appConfigurationProviderStub)
		vc.viewDidLoad()

		XCTAssert(vc.tableView.numberOfRows(inSection: 1) == 6)
	}

	func testDataReloadForUnsuccessfulDownload() {
		let fakeResult: (Result<SAP_Internal_V2_ApplicationConfigurationIOS, Error>) = .failure(URLSession.Response.Failure.noResponse)
		let appConfigurationProviderStub = AppConfigurationProviderStub(result: fakeResult)
		let vc = EUSettingsViewController(appConfigurationProvider: appConfigurationProviderStub)
		vc.viewDidLoad()

		XCTAssert(vc.tableView.numberOfRows(inSection: 1) == 1)
	}

}

private class AppConfigurationProviderStub: AppConfigurationProviding {

	let result: (Result<SAP_Internal_V2_ApplicationConfigurationIOS, Error>)

	init(result: (Result<SAP_Internal_V2_ApplicationConfigurationIOS, Error>)) {
		self.result = result
	}

	func appConfiguration(forceFetch: Bool, completion: @escaping Completion) {
		completion(result)
	}

	func appConfiguration(completion: @escaping Completion) {
		completion(result)
	}
}
