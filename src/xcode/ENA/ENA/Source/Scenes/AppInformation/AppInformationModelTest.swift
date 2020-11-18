//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class AppInformationModelTest: XCTestCase {
	
	func testAboutModel() {
		let dynamicTable = AppInformationModel.aboutModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.aboutModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 4)
	}

	func testContactModel() {
		let dynamicTable = AppInformationModel.contactModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.contactModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 6)
	}

	func testPrivacyModel() {
		let dynamicTable = AppInformationModel.privacyModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.privacyModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 2)
	}

	func testTermsModel() {
		let dynamicTable = AppInformationModel.termsModel
		XCTAssertEqual(dynamicTable.numberOfSection, 1)
		
		let section = AppInformationModel.termsModel.section(0)
		let numberOfCells = section.cells.count
		
		XCTAssertEqual(numberOfCells, 2)
	}
	
}
