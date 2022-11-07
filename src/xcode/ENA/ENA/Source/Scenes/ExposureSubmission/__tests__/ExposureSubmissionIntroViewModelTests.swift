////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionIntroViewModelTests: CWATestCase {

	func test_When_StoreHasTestProfile_Then_AntigenTestProfileTileIsReturned() {
		let store = MockTestStore()
		let antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		store.antigenTestProfiles = [antigenTestProfile]

		let viewModel = ExposureSubmissionIntroViewModel(
			onPositiveSelfTestButtonTap: { },
			onSelfReportSubmissionButtonTap: { },
			onQRCodeButtonTap: { _ in },
			onFindTestCentersTap: { },
			onRapidTestProfileTap: { },
			antigenTestProfileStore: store
		)

		let profileCell = viewModel.dynamicTableModel.cell(at: IndexPath(row: 5, section: 1))

		XCTAssertEqual(profileCell.tag, "AntigenTestProfileCard")
	}

	func test_When_DynamicTableViewModel_Then_NumberOfCellsAndTypeIsCorrect() {
		let store = MockTestStore()

		let viewModel = ExposureSubmissionIntroViewModel(
			onPositiveSelfTestButtonTap: { },
			onSelfReportSubmissionButtonTap: { },
			onQRCodeButtonTap: { _ in },
			onFindTestCentersTap: { },
			onRapidTestProfileTap: { },
			antigenTestProfileStore: store
		)

		let section0 = viewModel.dynamicTableModel.section(0)
		var cells = section0.cells
		XCTAssertEqual(cells.count, 0)
		
		let section1 = viewModel.dynamicTableModel.section(1)
		cells = section1.cells
		XCTAssertEqual(cells.count, 6)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "imageCardCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "imageCardCell")
		
		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "imageCardCell")
		
		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "imageCardCell")
		
		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "imageCardCell")
	}
}
