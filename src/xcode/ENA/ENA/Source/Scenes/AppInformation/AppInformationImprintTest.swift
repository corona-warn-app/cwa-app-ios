//
//  AppInformationImprintTest.swift
//  ENA
//
//  Created by Vogel, Andreas on 01.09.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
@testable import ENA

class AppInformationImprintTest: XCTestCase {

	func testImprintViewModel() {
		let model: [AppInformationViewController.Category: (text: String, accessibilityIdentifier: String?, action: DynamicAction)] = [
			.imprint: (
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: appInformationImprintModel.dynamicTable, withTitle:  AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		XCTAssertNotNil(model)
		XCTAssertTrue(model.count == 1)
		let key = model.first?.key
		XCTAssert(key == .imprint)
		
		let dynamicTable = appInformationImprintModel.dynamicTable
		XCTAssertTrue(dynamicTable.numberOfSection == 1)

		let section = appInformationImprintModel.dynamicTable.section(0)
		XCTAssertNotNil(section)
		let numberOfCells = section.cells.count
		XCTAssertTrue(numberOfCells == 9)

	}
}
