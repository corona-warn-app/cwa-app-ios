////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
// swiftlint:disable line_length
class HealthCertificateQRCodeCellViewModelTests: XCTestCase {

	func testGIVEN_OverviewViewModelWithValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyValidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithSoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

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

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlySoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

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

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlySoonExpiringVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testGIVEN_OverviewViewModelWithExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyExpiredVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyInvalidVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithBlockedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyBlockedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedGermanVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedAustrianVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "AT")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyBlockedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithRevokedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyRevokedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake(
								dateOfVaccination: "2021-06-01"
							)
						]
					)
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedGermanVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedAustrianVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "AT")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyRevokedVaccinationCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						vaccinationEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Impfzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
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
					digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyValidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithValidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyValidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
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
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					),
					webTokenHeader: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlySoonExpiringTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					),
					webTokenHeader: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlySoonExpiringTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
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
					digitalCovidCertificate: DigitalCovidCertificate.fake(
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
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyExpiredTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let date = Date()
		let dateTimeOfSampleCollection = ISO8601DateFormatter.string(from: date, timeZone: .current, formatOptions: .withInternetDateTime)
		let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)

		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake(
								dateTimeOfSampleCollection: dateTimeOfSampleCollection
							)
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Probenahme am \(formattedDate)")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithExpiredTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	
		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyExpiredTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyInvalidTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithBlockedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyBlockedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedGermanTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedItalianTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "IT")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyBlockedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithRevokedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyRevokedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					)
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedGermanTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedItalianTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "IT")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyRevokedTestCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						testEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Testzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							RecoveryEntry.fake(
								dateOfFirstPositiveNAAResult: "2022-03-01T07:12:45.132Z"
							)
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Positiver Test vom 01.03.22")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							RecoveryEntry.fake(
								dateOfFirstPositiveNAAResult: "2022-03-01T07:12:45.132Z"
							)
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Positiver Test vom 01.03.22")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .valid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyValidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .valid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertNil(viewModel.title)
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertNil(viewModel.validityStateIcon)
		XCTAssertNil(viewModel.validityStateTitle)
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithSoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake(
								dateOfFirstPositiveNAAResult: "2022-03-01T07:12:45.132Z"
							)
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Positiver Test vom 01.03.22")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

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

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlySoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake(
								dateOfFirstPositiveNAAResult: "2022-03-01T07:12:45.132Z"
							)
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.subtitle, "Positiver Test vom 01.03.22")
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

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

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testGIVEN_DetailsViewModelWithSoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlySoonExpiringRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(expirationTime: expirationDate)
				),
				validityState: .expiringSoon,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiringSoon"))
		XCTAssertEqual(
			viewModel.validityStateTitle,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyExpiredRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .expired,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.validityStateDescription, "Wenn dies eines Ihrer aktuell verwendeten Zertifikate ist, bemühen Sie sich bitte rechtzeitig darum, es zu erneuern. Im Zeitraum von 28 Tagen vor und bis zu 90 Tagen nach Ablauf können Sie es direkt über die App erneuern lassen, sofern es in Deutschland ausgestellt wurde. Sie finden die Option \"Zertifikate erneuern\" dann in Ihrer Zertifikatsübersicht unter der Kachel \"Status-Nachweis\". Sollte dies nicht eines Ihrer aktuell verwendeten Zertifikate sein, muss es nicht verlängert werden und Sie müssen nichts weiter tun.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyInvalidRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .invalid,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde von einer nicht autorisierten Stelle oder fehlerhaft ausgestellt. Bitte lassen Sie das Zertifikat von einer autorisierten Stelle erneut ausstellen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithBlockedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyBlockedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedGermanRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithBlockedDutchRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "NL")
				),
				validityState: .blocked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyBlockedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .blocked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertFalse(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithRevokedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_OverviewViewModelWithNewlyRevokedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .overview,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					)
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertNil(viewModel.validityStateDescription)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedGermanRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithRevokedDutchRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "NL")
				),
				validityState: .revoked
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das Zertifikat wurde vom Zertifikataussteller aufgrund einer behördlichen Entscheidung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	func testGIVEN_DetailsViewModelWithNewlyRevokedRecoveryCertificate_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			mode: .details,
			healthCertificate: try HealthCertificate(
				base45: try base45Fake(
					digitalCovidCertificate: DigitalCovidCertificate.fake(
						recoveryEntries: [
							.fake()
						]
					),
					webTokenHeader: .fake(issuer: "DE")
				),
				validityState: .revoked,
				isValidityStateNew: true
			),
			accessibilityText: "accessibilityText",
			onCovPassCheckInfoButtonTap: { }
		)

		// THEN
		XCTAssertEqual(viewModel.title, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subtitle)
		XCTAssertEqual(viewModel.qrCodeViewModel.accessibilityLabel, "accessibilityText")
		XCTAssertEqual(viewModel.qrCodeViewModel.covPassCheckInfoPosition, .top)

		XCTAssertEqual(viewModel.validityStateIcon, UIImage(named: "Icon_ExpiredInvalid"))
		XCTAssertEqual(viewModel.validityStateTitle, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.validityStateDescription, "Das RKI hat das Zertifikat aufgrund einer behördlichen Verfügung gesperrt. Bitte bemühen Sie sich darum, einen neuen digitalen Nachweis ausstellen zu lassen.")

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)

		XCTAssertTrue(viewModel.qrCodeViewModel.shouldBlockCertificateCode)
	}

	// swiftlint:disable file_length
}
