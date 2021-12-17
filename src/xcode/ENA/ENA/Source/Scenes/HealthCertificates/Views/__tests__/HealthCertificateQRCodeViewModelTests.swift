////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
class HealthCertificateQRCodeViewModelTests: XCTestCase {

	// MARK: - Vaccination Certificate

	func testValidVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testSoonExpiringVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expiringSoon
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testExpiredVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testInvalidVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedVaccinationCertificateShowingRealQRCode() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: true,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	// MARK: - Test Certificate

	func testValidTestCertificate() throws {
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
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testSoonExpiringTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .expiringSoon
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testExpiredTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testInvalidTestCertificate() throws {
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
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedTestCertificateShowingRealQRCode() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: true,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	// MARK: - Recovery Certificate

	func testValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .valid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testSoonExpiringRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .expiringSoon
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testExpiredRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .expired
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testInvalidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .invalid
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			"https://www.coronawarn.app/de/faq/#hc_signature_invalid"
		)

		XCTAssertTrue(viewModel.shouldBlockCertificateCode)
	}

	func testBlockedRecoveryCertificateShowingRealQRCode() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [.fake()]
				)
			),
			validityState: .blocked
		)

		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: true,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(viewModel.accessibilityLabel, "accessibilityLabel")

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			healthCertificate.base45
		)

		XCTAssertFalse(viewModel.shouldBlockCertificateCode)
	}

	func testImageUpdatedCorrectly() throws {
		let vaccinationCertificate = try vaccinationCertificate()
		let testCertificate = try testCertificate()


		let viewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: vaccinationCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			accessibilityLabel: "accessibilityLabel",
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: { }
		)

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			vaccinationCertificate.base45
		)

		viewModel.updateImage(with: testCertificate)

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			testCertificate.base45
		)

		viewModel.updateImage(with: vaccinationCertificate)

		XCTAssertEqual(
			viewModel.qrCodeImage?.parsedQRCodeStrings.first,
			vaccinationCertificate.base45
		)
	}

}

private extension UIImage {

	var parsedQRCodeStrings: [String] {
		guard let image = self.ciImage else {
			return []
		}

		let detector = CIDetector(
			ofType: CIDetectorTypeQRCode,
			context: nil,
			options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
		)

		let features = detector?.features(in: image) ?? []

		return features.compactMap {
			($0 as? CIQRCodeFeature)?.messageString
		}
	}

}
