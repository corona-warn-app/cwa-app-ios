////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class QRCodeCellViewModelTests: XCTestCase {

	func testGIVEN_CreateAntigenTestProfile_WHEN_vCardData_THEN_IsCorrect() throws {
		// GIVEN
		let  antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		let viewModel = QRCodeCellViewModel(
			antigenTestProfile: antigenTestProfile,
			backgroundColor: .white,
			borderColor: .red
		)

		// WHEN
		let qrCodeImage = try XCTUnwrap(UIImage.qrCode(
			with: viewModel.vCardV4,
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .medium
		))

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .white)
		XCTAssertEqual(viewModel.borderColor, .red)
		XCTAssertEqual(viewModel.qrCodeImage.pngData(), qrCodeImage.pngData())
	}

}
