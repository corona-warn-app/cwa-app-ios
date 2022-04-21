//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AntigenTestPersonProfileCellModelTests: XCTestCase {
	
	func testFullNameTitle() throws {
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

		let cellModel = try XCTUnwrap(
			AntigenTestPersonProfileCellModel(antigenTestProfile: antigenTestProfile)
		)

		XCTAssertEqual(cellModel.title, AppStrings.AntigenProfile.Overview.title)
		XCTAssertEqual(cellModel.name, "Max Mustermann")
	}
	
	func testQRCodeImage() throws {
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

		let cellModel = try XCTUnwrap(
			AntigenTestPersonProfileCellModel(antigenTestProfile: antigenTestProfile)
		)

		XCTAssertNotNil(cellModel.qrCodeViewModel.qrCodeImage())
	}
	
	func testBlueGradient() throws {
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

		let cellModel = try XCTUnwrap(
			AntigenTestPersonProfileCellModel(antigenTestProfile: antigenTestProfile)
		)

		XCTAssertEqual(cellModel.backgroundGradientType, .blueOnly)
	}

}
