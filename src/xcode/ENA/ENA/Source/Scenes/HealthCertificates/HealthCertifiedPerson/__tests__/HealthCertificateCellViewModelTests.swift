////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateCellViewModelTests: XCTestCase {

	func testViewModelWithIncompleteVaccinationCertificate() throws {
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
			)
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.detail, "geimpft am 01.06.21")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithSeriesCompletingVaccinationCertificateWithoutCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -14, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_FullyVaccinated_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithSeriesCompletingVaccinationCertificateWithCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.subheadline, "Impfung 2 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithTwoVaccinations_FirstVaccinationIsNotCurrentlyUsed() throws {
		let firstVaccinationCertificate = try vaccinationCertificate(daysOffset: -60, doseNumber: 1, totalSeriesOfDoses: 2)
		let secondVaccinationCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstVaccinationCertificate, secondVaccinationCertificate]
		)

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: firstVaccinationCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .solidGrey)
		XCTAssertEqual(viewModel.headline, "Impfzertifikat")
		XCTAssertEqual(viewModel.subheadline, "Impfung 1 von 2")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "VaccinationCertificate_PartiallyVaccinated_Icon"))
		XCTAssertFalse(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithPCRTestCertificate() throws {
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
			)
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.subheadline, "PCR-Test")
		XCTAssertEqual(viewModel.detail, "Probenahme am 29.05.21")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithAntigenTestCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					testEntries: [
						TestEntry.fake(
							typeOfTest: "LP217198-3",
							dateTimeOfSampleCollection: "2021-05-13T14:36:00.000Z"
						)
					]
				)
			)
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertEqual(viewModel.subheadline, "Schnelltest")
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithTestCertificateOfUnknownType() throws {
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
			)
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Testzertifikat")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "Probenahme am 13.05.21")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "TestCertificate_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

	func testViewModelWithRecoveryCertificate() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					recoveryEntries: [
						RecoveryEntry.fake(
							certificateValidUntil: "2022-03-18T07:12:45.132Z"
						)
					]
				)
			)
		)

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let viewModel = HealthCertificateCellViewModel(
			healthCertificate: healthCertificate,
			healthCertifiedPerson: healthCertifiedPerson
		)

		XCTAssertEqual(viewModel.gradientType, .lightBlue(withStars: false))
		XCTAssertEqual(viewModel.headline, "Genesenenzertifikat")
		XCTAssertNil(viewModel.subheadline)
		XCTAssertEqual(viewModel.detail, "gültig bis 18.03.22")
		XCTAssertEqual(viewModel.image, UIImage(imageLiteralResourceName: "RecoveryCertificate_Icon"))
		XCTAssertTrue(viewModel.isCurrentlyUsedCertificateHintVisible)
	}

}
