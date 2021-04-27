////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionIntroViewModelTests: XCTestCase {

	func test_When_StoreHasNOTestProfile_Then_CreateProfileTileIsReturned() {
		let store = MockTestStore()
		store.antigenTestProfile = nil

		let viewModel = ExposureSubmissionIntroViewModel(
			onQRCodeButtonTap: { _ in },
			onTANButtonTap: { },
			onHotlineButtonTap: { },
			onRapidTestProfileTap: { },
			antigenTestProfileStore: store
		)

		let profileCell = viewModel.dynamicTableModel.cell(at: IndexPath(row: 1, section: 1))

		XCTAssertEqual(profileCell.tag, "AntigenTestCreateProfileCard")
	}

	func test_When_StoreHasTestProfile_Then_CreateProfileTileIsReturned() {
		let store = MockTestStore()
		store.antigenTestProfile = AntigenTestProfile()

		let viewModel = ExposureSubmissionIntroViewModel(
			onQRCodeButtonTap: { _ in },
			onTANButtonTap: { },
			onHotlineButtonTap: { },
			onRapidTestProfileTap: { },
			antigenTestProfileStore: store
		)

		let profileCell = viewModel.dynamicTableModel.cell(at: IndexPath(row: 1, section: 1))

		XCTAssertEqual(profileCell.tag, "AntigenTestProfileCard")
	}

}
