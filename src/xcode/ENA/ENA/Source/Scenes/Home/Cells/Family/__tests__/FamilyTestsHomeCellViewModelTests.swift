//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FamilyTestsHomeCellViewModelTests: XCTestCase {

	func testGIVEN_BadgeCountIsZero_WHEN_detailsText_THEN_isHidden() {
		// GIVEN
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		let viewModel = FamilyTestsHomeCellViewModel(familyMemberCoronaTestService: familyMemberCoronaTestService, onUpdate: {})

		// WHEN
		let title = viewModel.titleText
		let badgeText = viewModel.badgeText
		let detail = viewModel.detailText
		let isHidden = viewModel.isDetailsHidden

		// THEN
		XCTAssertEqual(title, AppStrings.Home.familyTestTitle)
		XCTAssertNil(badgeText)
		XCTAssertNil(detail)
		XCTAssertTrue(isHidden)
	}

	func testGIVEN_BadgeCountIsGreaterZero_WHEN_detailsText_THEN_isHidden() {
		// GIVEN
		let familyMemberCoronaTestService = MockFamilyMemberCoronaTestService()
		familyMemberCoronaTestService.unseenNewsCount = 10
		let viewModel = FamilyTestsHomeCellViewModel(familyMemberCoronaTestService: familyMemberCoronaTestService, onUpdate: {})

		// WHEN
		let title = viewModel.titleText
		let badgeText = viewModel.badgeText
		let detail = viewModel.detailText
		let isHidden = viewModel.isDetailsHidden

		// THEN
		XCTAssertEqual(title, AppStrings.Home.familyTestTitle)
		XCTAssertEqual(badgeText, "10")
		XCTAssertEqual(detail, AppStrings.Home.familyTestDetail)
		XCTAssertFalse(isHidden)
	}


}
