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

import Foundation
import XCTest
@testable import ENA

class AppInformationImprintTest: XCTestCase {

	func testImprintViewModelDE() throws {
		let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: "de")
		let model: [AppInformationViewController.Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
			.imprint: (
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: imprintViewModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		XCTAssertNotNil(model)
		XCTAssertEqual(model.count, 1)
		let key = model.first?.key
		XCTAssertEqual(key, .imprint)
		
		let dynamicTable = try XCTUnwrap(imprintViewModel.dynamicTable)
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = imprintViewModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 9) //DE EN
	}

	
	func testImprintViewModelEN() throws {
		let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: "en")
		let model: [AppInformationViewController.Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
			.imprint: (
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: imprintViewModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		XCTAssertNotNil(model)
		XCTAssertEqual(model.count, 1)
		let key = model.first?.key
		XCTAssertEqual(key, .imprint)
		
		let dynamicTable = try XCTUnwrap(imprintViewModel.dynamicTable)
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = imprintViewModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 9) //DE EN
	}


	func testImprintViewModelTR() throws {
		let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: "tr")
		
		let model: [AppInformationViewController.Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
			.imprint: (
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: imprintViewModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		XCTAssertNotNil(model)
		XCTAssertEqual(model.count, 1)
		let key = model.first?.key
		XCTAssertEqual(key, .imprint)
		
		let dynamicTable = try XCTUnwrap(imprintViewModel.dynamicTable)
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = imprintViewModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 10)// not DE EN
	}
	
	func testContactFormDE() {
		let cellCollection = AppInformationImprintViewModel.contactForms(localization: "de")
		XCTAssertEqual(cellCollection.count, 1) //DE EN
	}

	func testContactFormEN() {
		let cellCollection = AppInformationImprintViewModel.contactForms(localization: "en")
		XCTAssertEqual(cellCollection.count, 1) //DE EN
	}

	func testContactFormTR() {
		let cellCollection = AppInformationImprintViewModel.contactForms(localization: "tr")
		XCTAssertEqual(cellCollection.count, 2) //not DE EN
	}
	
}
