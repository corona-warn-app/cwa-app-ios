////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeThankYouCellModelTests: XCTestCase {

	func testGIVEN_CellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let cellModel = HomeThankYouCellModel()

		// THEN
		XCTAssertEqual(cellModel.title, AppStrings.Home.thankYouCardTitle)
		XCTAssertEqual(cellModel.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(cellModel.imageName, "Illu_Submission_VielenDank")
		XCTAssertEqual(cellModel.body, AppStrings.Home.thankYouCardBody)
		XCTAssertEqual(cellModel.noteTitle, AppStrings.Home.thankYouCardNoteTitle)
		XCTAssertEqual(cellModel.furtherInfoTitle, AppStrings.Home.thankYouCardFurtherInfoItemTitle)
		XCTAssertEqual(cellModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(cellModel.iconColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(cellModel.homeItemViewModels.count, 2)
		XCTAssertEqual(cellModel.furtherHomeItemViewModels.count, 4)
	}

	func testGIVEN_CellModel_WHEN_HomeItemViewModels_THEN_InitilizedAsExpected() throws {
		// GIVEN
		let cellModel = HomeThankYouCellModel()

		// WHEN
		let firstHomeItemViewModels = try XCTUnwrap(cellModel.homeItemViewModels[0] as? HomeImageItemViewModel)
		let secoundHmeItemViewModels = try XCTUnwrap(cellModel.homeItemViewModels[1] as? HomeImageItemViewModel)

		// THEN
		XCTAssertEqual(firstHomeItemViewModels.title, AppStrings.Home.thankYouCardPhoneItemTitle)
		XCTAssertEqual(firstHomeItemViewModels.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(firstHomeItemViewModels.iconImageName, "Icons - Hotline")
		XCTAssertEqual(firstHomeItemViewModels.iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(firstHomeItemViewModels.color, .clear)
		XCTAssertEqual(firstHomeItemViewModels.separatorColor, .clear)

		XCTAssertEqual(secoundHmeItemViewModels.title, AppStrings.Home.thankYouCardHomeItemTitle)
		XCTAssertEqual(secoundHmeItemViewModels.titleColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(secoundHmeItemViewModels.iconImageName, "Icons - Home")
		XCTAssertEqual(secoundHmeItemViewModels.iconTintColor, .enaColor(for: .riskHigh))
		XCTAssertEqual(secoundHmeItemViewModels.color, .clear)
		XCTAssertEqual(secoundHmeItemViewModels.separatorColor, .clear)
	}

	func testGIVEN_CellModel_WHEN_FurtherHomeItemViewModels_THEN_InitilizedAsExpected() throws {
		// GIVEN
		let cellModel = HomeThankYouCellModel()

		// WHEN
		let firstHomeItemViewModels = try XCTUnwrap(cellModel.furtherHomeItemViewModels[0] as? HomeListItemViewModel)
		let secoundHmeItemViewModels = try XCTUnwrap(cellModel.furtherHomeItemViewModels[1] as? HomeListItemViewModel)
		let thirdHomeItemViewModels = try XCTUnwrap(cellModel.furtherHomeItemViewModels[2] as? HomeListItemViewModel)
		let fourthHmeItemViewModels = try XCTUnwrap(cellModel.furtherHomeItemViewModels[3] as? HomeListItemViewModel)

		// THEN
		XCTAssertEqual(firstHomeItemViewModels.text, AppStrings.Home.thankYouCard14DaysItemTitle)
		XCTAssertEqual(firstHomeItemViewModels.textColor, .enaColor(for: .textPrimary1))

		XCTAssertEqual(secoundHmeItemViewModels.text, AppStrings.Home.thankYouCardContactsItemTitle)
		XCTAssertEqual(secoundHmeItemViewModels.textColor, .enaColor(for: .textPrimary1))

		XCTAssertEqual(thirdHomeItemViewModels.text, AppStrings.Home.thankYouCardAppItemTitle)
		XCTAssertEqual(thirdHomeItemViewModels.textColor, .enaColor(for: .textPrimary1))

		XCTAssertEqual(fourthHmeItemViewModels.text, AppStrings.Home.thankYouCardNoSymptomsItemTitle)
		XCTAssertEqual(fourthHmeItemViewModels.textColor, .enaColor(for: .textPrimary1))
	}

}
