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

class ENSettingEuTracingViewModelTests: XCTestCase {
	
	func testENSettingEuTracingViewModelTests_Init() throws {
		let euTracingSettings = EUTracingSettings()
		let viewModel = ENSettingEuTracingViewModel(euTracingSettings: euTracingSettings)
		XCTAssertNotNil(viewModel)
	}
	
	func testENSettingEuTracingViewModelTests_LabelsAsExpected() throws {
		var euTracingSettings = EUTracingSettings()
		var viewModel = ENSettingEuTracingViewModel(euTracingSettings: euTracingSettings)
		
		
		XCTAssertNotEqual(viewModel.title, "", "Localized (i18n) Title should not be empty)")
		XCTAssertEqual(viewModel.countryListLabel, "", "Selected country list label should be empty.")
		XCTAssertEqual(viewModel.allCountriesEnbledStateLabel, "Aus", "Das deutsche Label sollte 'Aus' sein")
		
		euTracingSettings = EUTracingSettings(isAllCountriesEnbled: true, enabledCountries: ["FR", "IT"])
		viewModel = ENSettingEuTracingViewModel(euTracingSettings: euTracingSettings)
		XCTAssertEqual(viewModel.allCountriesEnbledStateLabel, "Ein", "The German label should be 'Aus'")
		XCTAssertEqual(viewModel.countryListLabel, "Frankreich, Italien", "The German localized label should be 'Frankreich, Italien'")
		
		

	}
}
