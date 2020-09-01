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

import XCTest
@testable import ENA

class AppInformationImprintTest: XCTestCase {

	func testImprintViewModel() {
		let model: [AppInformationViewController.Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
			.imprint: (
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: AppInformationImprintModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		XCTAssertNotNil(model)
		XCTAssertTrue(model.count == 1)
		let key = model.first?.key
		XCTAssert(key == .imprint)
		
		let dynamicTable = AppInformationImprintModel.dynamicTable
		XCTAssertTrue(dynamicTable.numberOfSection == 1)
		
		let section = AppInformationImprintModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		let localization = Bundle.main.preferredLocalizations.first
		if localization == "en" || localization == "de" {
			XCTAssertTrue(numberOfCells == 9) //DE EN
		} else {
			XCTAssertTrue(numberOfCells == 10)//else
		}

	}
	
	func testContactForm() {
		let cellCollection = AppInformationImprintModel.contactForms()
		let numberOfCells = cellCollection.count
		
		let localization = Bundle.main.preferredLocalizations.first
		if localization == "en" || localization == "de" {
			XCTAssertTrue(numberOfCells == 1) //DE EN
		} else {
			XCTAssertTrue(numberOfCells == 2) //else
		}
	}
	
}
