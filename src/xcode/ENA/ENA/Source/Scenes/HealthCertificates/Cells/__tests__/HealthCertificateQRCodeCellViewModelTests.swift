////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
class HealthCertificateQRCodeCellViewModelTests: XCTestCase {

	func testGIVEN_OverviewViewModelWithValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithSoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					),
					and: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					and: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Bitte bemühen Sie sich rechtzeitig darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Ablaufdatum wurde überschritten. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithValidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithValidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithSoonExpiringTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					),
					and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithExpiredTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithExpiredTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							RecoveryEntry.fake(
								certificateValidUntil: "2021-12-03T07:12:45.132Z"
							)
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "gültig bis 03.12.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithSoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake(
								certificateValidUntil: "2021-12-03T07:12:45.132Z"
							)
						]
					),
					and: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "gültig bis 03.12.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					and: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Bitte bemühen Sie sich rechtzeitig darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Ablaufdatum wurde überschritten. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_OverviewViewModelWithInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: { _, _ in }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertTrue(viewModel.isValidationButtonVisible)
	}

	func testGIVEN_DetailsViewModelWithInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onValidationButtonTap: nil
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isValidationButtonVisible)
	}

	// swiftlint:disable file_length
}
