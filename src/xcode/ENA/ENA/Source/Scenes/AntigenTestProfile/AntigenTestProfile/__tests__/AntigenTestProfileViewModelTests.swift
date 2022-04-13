////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestProfileViewModelTests: CWATestCase {

	func testGIVEN_AntigenTestProfileViewModel_THEN_NumberOfSectionsIMatches() {
		// GIVEN
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
		
		let viewModel = AntigenTestProfileViewModel(antigenTestProfile: antigenTestProfile, store: store)

		// THEN
		XCTAssertNotNil(viewModel.headerCellViewModel)
		XCTAssertNotNil(viewModel.noticeCellViewModel)
		XCTAssertNotNil(viewModel.qrCodeCellViewModel)
		XCTAssertNotNil(viewModel.profileCellViewModel)
		XCTAssertEqual(viewModel.numberOfSections, 4)
		XCTAssertEqual(viewModel.numberOfItems(in: .header), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .notice), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .profile), 1)
	}

	func testGIVEN_AntigenTestProfileViewModel_WHEN_DeleteProfil_THEN_RemovedFromStore() {
		// GIVEN
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
		
		let viewModel = AntigenTestProfileViewModel(antigenTestProfile: antigenTestProfile, store: store)

		// WHEN
		viewModel.deleteProfile()

		// THEN
		XCTAssertNil(store.antigenTestProfile)
	}

}
