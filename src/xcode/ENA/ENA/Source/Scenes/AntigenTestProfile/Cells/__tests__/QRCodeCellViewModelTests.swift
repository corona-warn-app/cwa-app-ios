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
		let revDate = Date()
		let qrCodeImage = try XCTUnwrap(UIImage.qrCode(
			with: viewModel.vCardV4(revDate: revDate),
			encoding: .utf8,
			size: CGSize(width: 280.0, height: 280.0),
			qrCodeErrorCorrectionLevel: .medium
		))

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .white)
		XCTAssertEqual(viewModel.borderColor, .red)
		XCTAssertEqual(viewModel.qrCodeImage(revDate: revDate).pngData(), qrCodeImage.pngData())
	}

	func testGIVEN_AntigenTestProfile_WHEN_getVCardV4Strong_THEN_FormatIsCorrect() {
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
		let revDate = Date()
		let revDateString = DateFormatter.VCard.revDate.string(from: revDate)
		let vCardString = viewModel.vCardV4(revDate: revDate)

		// THEN
		XCTAssertEqual(vCardString, """
		BEGIN:VCARD
		VERSION:4.0
		N:Max;Mustermann;;;
		FN:Max Mustermann
		BDAY:19820512
		EMAIL;TYPE=home:sabine.schulz@gmx.com
		TEL;TYPE="cell,home":0165434563
		ADR;type=home:;;Blumenstraße 2;Berlin;;43923;
		REV:\(revDateString)
		END:VCARD
		"""
		)
	}

}
