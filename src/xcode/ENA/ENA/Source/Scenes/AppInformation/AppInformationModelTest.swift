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
}
