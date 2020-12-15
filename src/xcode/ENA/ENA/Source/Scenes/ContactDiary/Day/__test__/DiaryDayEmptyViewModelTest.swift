//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayEmptyViewModelTest: XCTestCase {

	func testContactPerson() throws {
		let viewModel = DiaryDayEmptyViewModel(entryType: .contactPerson)

		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Diary_ContactPerson_Empty"))
		XCTAssertEqual(viewModel.title, AppStrings.ContactDiary.Day.contactPersonsEmptyTitle)
		XCTAssertEqual(viewModel.description, AppStrings.ContactDiary.Day.contactPersonsEmptyDescription)
	}

	func testLocation() throws {
		let viewModel = DiaryDayEmptyViewModel(entryType: .location)

		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Diary_Location_Empty"))
		XCTAssertEqual(viewModel.title, AppStrings.ContactDiary.Day.locationsEmptyTitle)
		XCTAssertEqual(viewModel.description, AppStrings.ContactDiary.Day.locationsEmptyDescription)
	}
	
}
