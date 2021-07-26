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
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							VaccinationEntry.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				)
			),
			accessibilityText: nil,
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "geimpft am 01.06.21")
		XCTAssertNil(viewModel.accessibilityText)
	}

	func testGIVEN_ViewModelWithTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							TestEntry.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					)
				)
			),
			accessibilityText: nil,
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertNil(viewModel.accessibilityText)
	}

	func testGIVEN_ViewModelWithRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							RecoveryEntry.fake(
								certificateValidUntil: "2021-12-03T07:12:45.132Z"
							)
						]
					)
				)
			),
			accessibilityText: nil,
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "gültig bis 03.12.21")
		XCTAssertNil(viewModel.accessibilityText)
	}

}
