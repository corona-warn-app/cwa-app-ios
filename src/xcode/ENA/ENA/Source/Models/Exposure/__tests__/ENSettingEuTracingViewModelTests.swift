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
		
		let viewModel = ENSettingEuTracingViewModel()
		XCTAssertNotNil(viewModel)
	}
	
	func testCellSelectedBackgroundColor_clear() throws {
		let viewModel = ENSettingEuTracingViewModel()
		let cell = EuTracingTableViewCell()
		cell.configure(using: viewModel)
		
		XCTAssertEqual(cell.selectedBackgroundView?.backgroundColor, UIColor.clear, "Background color of 'cell selected' state should be UIColor.clear")
	}
	
	func testENSettingEuTracingViewModelTests_LabelsAsExpected() throws {
		
		let viewModel = ENSettingEuTracingViewModel()
		
		XCTAssertNotEqual(viewModel.title, "", "Localized (i18n) Title should not be empty)")
		XCTAssertNotEqual(viewModel.countryListLabel, "", "Sub title label should be empty.")
	}
}
