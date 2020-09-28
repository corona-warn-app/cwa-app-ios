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
		let client = ClientMock()
		client.onSupportedCountries = { completion in
			let countries = [Country(countryCode: "DE"), Country(countryCode: "ES"), Country(countryCode: "FR"), Country(countryCode: "IT"), Country(countryCode: "IE"), Country(countryCode: "DK")].compactMap { $0 }
			completion(.success(countries))
		}
		let vc = EUSettingsViewController()

		vc.client = client
		vc.viewDidLoad()

		XCTAssert(vc.dynamicTableViewModel.numberOfRows(inSection: 1, for: vc) == 6)
	}

	func testDataReloadForUnsuccessfulDownload() {
		let client = ClientMock()
		client.onSupportedCountries = { completion in
			completion(.failure(.noResponse))
		}
		let vc = EUSettingsViewController()

		vc.client = client
		vc.viewDidLoad()

		XCTAssert(vc.dynamicTableViewModel.numberOfRows(inSection: 1, for: vc) == 1)
	}

}
