////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateQRCodeCellViewModelTests: XCTestCase {

	func testGIVEN_ViewModelWithVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalGreenCertificate.fake(
						vaccinationEntries: [
							VaccinationEntry.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				)
			),
			accessibilityText: nil
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "geimpft am 01.06.2021")
		XCTAssertNil(viewModel.accessibilityText)
	}

	func testGIVEN_ViewModelWithTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalGreenCertificate.fake(
						testEntries: [
							TestEntry.fake(
								dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
							)
						]
					)
				)
			),
			accessibilityText: nil
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am 29.05.2021")
		XCTAssertNil(viewModel.accessibilityText)
	}

	func testGIVEN_ViewModelWithRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalGreenCertificate.fake(
						recoveryEntries: [
							RecoveryEntry.fake(
								certificateValidUntil: "2021-12-03T07:12:45.132Z"
							)
						]
					)
				)
			),
			accessibilityText: nil
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "gültig bis 03.12.2021")
		XCTAssertNil(viewModel.accessibilityText)
	}

}
