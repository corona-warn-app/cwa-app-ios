////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

// swiftlint:disable type_body_length
class HealthCertificateCellViewModelTests: XCTestCase {

	// MARK: - .allDetails

	func testAllDetailsViewModelWithValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithNewValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Neu")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithJust3of3BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: 0, doseNumber: 3, totalSeriesOfDoses: 3)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .darkBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .darkBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 3 von 3")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_dark"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithJust2of1BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: 0, doseNumber: 2, totalSeriesOfDoses: 1)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .mediumBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .mediumBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 1")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_medium"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithSeriesCompletingVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithTwoVaccinations_FirstVaccinationIsNotCurrentlyUsed() throws {
		let firstVaccinationCertificate = try vaccinationCertificate(daysOffset: -60, doseNumber: 1, totalSeriesOfDoses: 2)
		let secondVaccinationCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstVaccinationCertificate, secondVaccinationCertificate]
		)

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: firstVaccinationCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithSoonExpiringIncompleteVaccinationCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertEqual(
			viewModel.validityStateInfo,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithExpiredIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithInvalidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithBlockedIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithNewValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Neu")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithSoonExpiringAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithSoonExpiringNewAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Neu")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithExpiredTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithExpiredNewTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Neu")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithInvalidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithBlockedAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithNewValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(viewModel.validityStateInfo, "Neu")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithSoonExpiringRecoveryCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(
			viewModel.validityStateInfo,
			String(
				format: "Zertifikat läuft am %@ um %@ ab",
				DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: expirationDate, dateStyle: .none, timeStyle: .short)
			)
		)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_light"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithExpiredRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat abgelaufen")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithInvalidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat (Signatur) ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testAllDetailsViewModelWithBlockedRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(viewModel.validityStateInfo, "Zertifikat ungültig")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertEqual(viewModel.currentlyUsedImage, UIImage(named: "Icon_CurrentlyUsedCertificate_grey"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testForAllDetailsIsUnseenNewsIndicatorVisibleFalseWithoutNews() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForAllDetailsIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithOldValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForAllDetailsIsUnseenNewsIndicatorVisibleTrueForOldHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForAllDetailsIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .allDetails
		)

		XCTAssertTrue(viewModel.isUnseenNewsIndicatorVisible)
	}

	// MARK: - .overview

	func testOverviewViewModelWithValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithNewValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithJust3of3BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: 0, doseNumber: 3, totalSeriesOfDoses: 3)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .darkBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 3 von 3")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithJust2of1BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: 0, doseNumber: 2, totalSeriesOfDoses: 1)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .darkBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 1")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithSeriesCompletingVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithTwoVaccinations_FirstVaccinationIsNotCurrentlyUsed() throws {
		let firstVaccinationCertificate = try vaccinationCertificate(daysOffset: -60, doseNumber: 1, totalSeriesOfDoses: 2)
		let secondVaccinationCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstVaccinationCertificate, secondVaccinationCertificate]
		)

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: firstVaccinationCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithSoonExpiringIncompleteVaccinationCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithExpiredIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithInvalidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithBlockedIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithNewValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithSoonExpiringAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithSoonExpiringNewAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithExpiredTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithExpiredNewTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithInvalidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithBlockedAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithNewValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithSoonExpiringRecoveryCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithExpiredRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithInvalidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewViewModelWithBlockedRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.name)
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testForOverviewIsUnseenNewsIndicatorVisibleFalseWithoutNews() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithOldValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewIsUnseenNewsIndicatorVisibleTrueForOldHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overview
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	// MARK: - .overviewPlusName

	func testOverviewPlusNameViewModelWithValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Guendling", givenName: "Nick"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Nick Guendling")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithNewValidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Teuber", givenName: "Kai-Marcel"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Kai-Marcel Teuber")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithJust3of3BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(
			doseNumber: 3,
			totalSeriesOfDoses: 3,
			name: .fake(familyName: "Scherer", givenName: "Marcus")
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .darkBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Marcus Scherer")
		XCTAssertEqual(viewModel.subheadline, "Impfung 3 von 3")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithJust2of1BoosterVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(
			doseNumber: 2,
			totalSeriesOfDoses: 1,
			name: .fake(familyName: "Friesen", givenName: "Artur")
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])
		healthCertifiedPerson.gradientType = .darkBlue

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Artur Friesen")
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 1")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithSeriesCompletingVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(
			daysOffset: -15,
			doseNumber: 2,
			totalSeriesOfDoses: 2,
			name: .fake(familyName: "Brause", givenName: "Pascal")
		)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Pascal Brause")
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithTwoVaccinations_FirstVaccinationIsNotCurrentlyUsed() throws {
		let firstVaccinationCertificate = try vaccinationCertificate(
			daysOffset: -60,
			doseNumber: 1,
			totalSeriesOfDoses: 2,
			name: .fake(familyName: "Khalid", givenName: "Naveed")
		)
		let secondVaccinationCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstVaccinationCertificate, secondVaccinationCertificate]
		)

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: firstVaccinationCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Naveed Khalid")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithSoonExpiringIncompleteVaccinationCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Ahmed", givenName: "Omar Abdelaziz Hanafy Abdelaziz"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Omar Abdelaziz Hanafy Abdelaziz Ahmed")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithExpiredIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Guendling", givenName: "Nick"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Nick Guendling")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithInvalidIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Teuber", givenName: "Kai-Marcel"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Kai-Marcel Teuber")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithBlockedIncompleteVaccinationCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Scherer", givenName: "Marcus"),
					vaccinationEntries: [
						VaccinationEntry.fake(
							doseNumber: 1,
							totalSeriesOfDoses: 2,
							dateOfVaccination: "2021-06-01"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.name, "Marcus Scherer")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "Geimpft am 01.06.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Friesen", givenName: "Artur"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Artur Friesen")
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithNewValidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Brause", givenName: "Pascal"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Pascal Brause")
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithSoonExpiringAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Khalid", givenName: "Naveed"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Naveed Khalid")
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithSoonExpiringNewAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Ahmed", givenName: "Omar Abdelaziz Hanafy Abdelaziz"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				),
				and: .fake(expirationTime: Date(timeIntervalSince1970: 1627987295))
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Omar Abdelaziz Hanafy Abdelaziz Ahmed")
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithExpiredTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Guendling", givenName: "Nick"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Nick Guendling")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithExpiredNewTestCertificateOfUnknownType() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Teuber", givenName: "Kai-Marcel"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP123456-7",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Kai-Marcel Teuber")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithInvalidPCRTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Scherer", givenName: "Marcus"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP6464-4",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Marcus Scherer")
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithBlockedAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Friesen", givenName: "Artur"),
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-29T14:36:00.000Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.name, "Artur Friesen")
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Brause", givenName: "Pascal"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Pascal Brause")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithNewValidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Khalid", givenName: "Naveed"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .valid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Naveed Khalid")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithSoonExpiringRecoveryCertificate() throws {
		let expirationDate = Date(timeIntervalSince1970: 1627987295)
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Ahmed", givenName: "Omar Abdelaziz Hanafy Abdelaziz"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				),
				and: .fake(expirationTime: expirationDate)
			),
			validityState: .expiringSoon,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Omar Abdelaziz Hanafy Abdelaziz Ahmed")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithExpiredRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Guendling", givenName: "Nick"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .expired,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Nick Guendling")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithInvalidRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Teuber", givenName: "Kai-Marcel"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .invalid,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Kai-Marcel Teuber")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testOverviewPlusNameViewModelWithBlockedRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					name: .fake(familyName: "Scherer", givenName: "Marcus"),
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			),
			validityState: .blocked,
			isNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue)
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertEqual(viewModel.name, "Marcus Scherer")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertNil(viewModel.validityStateInfo)
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "Icon_WarningTriangle_small"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testForOverviewPlusNameIsUnseenNewsIndicatorVisibleFalseWithoutNews() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewPlusNameIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithOldValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: false
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewPlusNameIsUnseenNewsIndicatorVisibleTrueForOldHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: false,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	func testForOverviewPlusNameIsUnseenNewsIndicatorVisibleTrueForNewHealthCertificateWithNewValidityState() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson,
			details: .overviewPlusName
		)

		XCTAssertFalse(viewModel.isUnseenNewsIndicatorVisible)
	}

	// swiftlint:disable:next file_length
}
