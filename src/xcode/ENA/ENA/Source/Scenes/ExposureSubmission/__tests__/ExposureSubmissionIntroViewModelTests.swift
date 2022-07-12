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
			onQRCodeButtonTap: { _ in },
			onFindTestCentersTap: { },
			onTANButtonTap: { },
			onHotlineButtonTap: { },
			onRapidTestProfileTap: { },
			antigenTestProfileStore: store
		)

		let profileCell = viewModel.dynamicTableModel.cell(at: IndexPath(row: 2, section: 1))

		XCTAssertEqual(profileCell.tag, "AntigenTestProfileCard")
	}

}
