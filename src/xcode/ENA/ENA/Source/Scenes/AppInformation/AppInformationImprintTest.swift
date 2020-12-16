//
// 🦠 Corona-Warn-App
//

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
		
		XCTAssertEqual(model.count, 1)
		let key = model.first?.key
		XCTAssertEqual(key, .imprint)
		
		let dynamicTable = try XCTUnwrap(imprintViewModel.dynamicTable)
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = imprintViewModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 9) // DE EN
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
		
		XCTAssertEqual(model.count, 1)
		let key = model.first?.key
		XCTAssertEqual(key, .imprint)
		
		let dynamicTable = try XCTUnwrap(imprintViewModel.dynamicTable)
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = imprintViewModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 9) // DE EN
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
		XCTAssertEqual(cellCollection.count, 1) // DE EN
	}

	func testContactFormEN() {
		let cellCollection = AppInformationImprintViewModel.contactForms(localization: "en")
		XCTAssertEqual(cellCollection.count, 1) // DE EN
	}

	func testContactFormTR() {
		let cellCollection = AppInformationImprintViewModel.contactForms(localization: "tr")
		XCTAssertEqual(cellCollection.count, 2) // not DE EN
	}
	
}
