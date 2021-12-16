//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayAddCellModelTest: CWATestCase {

	func testContactPerson() throws {
		let cellModel = DiaryDayAddCellModel(entryType: .contactPerson)

		XCTAssertEqual(cellModel.text, AppStrings.ContactDiary.Day.addContactPerson)
	}

	func testLocation() throws {
		let cellModel = DiaryDayAddCellModel(entryType: .location)

		XCTAssertEqual(cellModel.text, AppStrings.ContactDiary.Day.addLocation)
	}
	
}
