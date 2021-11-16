//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateQRCodeViewTests: XCTestCase {

	func testGIVEN_QRCodeView_WHEN_ConfigureWithValidHealthcertificate_THEN_NoticeLabelIsVisible() throws {
		// GIVEN
		let qrCodeView = HealthCertificateQRCodeView(frame: CGRect(x: 0, y: 0, width: 320, height: 240))

		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "",
			showInfoHit: {}
		)

		// WHEN
		qrCodeView.configure(with: viewModel)

		// THEN
		XCTAssertFalse(qrCodeView.noticeLabelIsHidden)
		XCTAssertFalse(qrCodeView.infoButtonIsHidden)
	}

	func testGIVEN_QRCodeView_WHEN_ConfigureWithInvalidHealthcertificate_THEN_NoticeLabelIsNotisible() throws {
		// GIVEN
		let qrCodeView = HealthCertificateQRCodeView(frame: CGRect(x: 0, y: 0, width: 320, height: 240))

		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "",
			showInfoHit: {}
		)

		// WHEN
		qrCodeView.configure(with: viewModel)

		// THEN
		XCTAssertTrue(qrCodeView.noticeLabelIsHidden)
		XCTAssertTrue(qrCodeView.infoButtonIsHidden)
	}

}
