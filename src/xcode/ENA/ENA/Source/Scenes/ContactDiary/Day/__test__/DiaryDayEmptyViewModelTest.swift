//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayEmptyViewModelTest: XCTestCase {

	func testContactPerson() throws {
		let viewModel = DiaryDayEmptyStateViewModel(entryType: .contactPerson)

		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Diary_ContactPerson_Empty"))
		XCTAssertEqual(viewModel.title, AppStrings.ContactDiary.Day.contactPersonsEmptyTitle)
		XCTAssertEqual(viewModel.description, AppStrings.ContactDiary.Day.contactPersonsEmptyDescription)
		XCTAssertEqual(viewModel.imageDescription, AppStrings.ContactDiary.Day.contactPersonsEmptyImageDescription)
	}

	func testLocation() throws {
		let viewModel = DiaryDayEmptyStateViewModel(entryType: .location)

		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Diary_Location_Empty"))
		XCTAssertEqual(viewModel.title, AppStrings.ContactDiary.Day.locationsEmptyTitle)
		XCTAssertEqual(viewModel.description, AppStrings.ContactDiary.Day.locationsEmptyDescription)
		XCTAssertEqual(viewModel.imageDescription, AppStrings.ContactDiary.Day.locationsEmptyImageDescription)
	}
	
}
