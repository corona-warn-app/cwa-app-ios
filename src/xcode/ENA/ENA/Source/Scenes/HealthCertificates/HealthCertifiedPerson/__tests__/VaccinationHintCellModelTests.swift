////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit
import class CertLogic.Description

class VaccinationHintCellModelTests: XCTestCase {

	func testVaccinationHintAfterFirstVaccination() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -1, doseNumber: 1, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 1 Tag")
		XCTAssertEqual(cellModel.description, "Sie haben noch nicht alle derzeit geplanten Impfungen erhalten. Daher ist Ihr Impfschutz noch nicht vollständig.")

		XCTAssertNil(cellModel.faqLink)
		XCTAssertFalse(cellModel.isUnseenNewsIndicatorVisible)
	}

	func testVaccinationHint15DaysBeforeCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: 0, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung heute")
		XCTAssertEqual(cellModel.description, "Sie haben nun alle derzeit geplanten Impfungen erhalten. Allerdings ist der Impfschutz erst in 15 Tagen vollständig.")

		XCTAssertNil(cellModel.faqLink)
		XCTAssertFalse(cellModel.isUnseenNewsIndicatorVisible)
	}

	func testVaccinationHint1DayBeforeCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -14, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 14 Tagen")
		XCTAssertEqual(cellModel.description, "Sie haben nun alle derzeit geplanten Impfungen erhalten. Allerdings ist der Impfschutz erst morgen vollständig.")

		XCTAssertNil(cellModel.faqLink)
		XCTAssertFalse(cellModel.isUnseenNewsIndicatorVisible)
	}

	func testVaccinationHintForCompleteProtection() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -15, doseNumber: 2, totalSeriesOfDoses: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 15 Tagen")
		XCTAssertEqual(cellModel.description, "Sie haben nun alle derzeit geplanten Impfungen erhalten. Ihr Impfschutz ist vollständig.")

		XCTAssertNil(cellModel.faqLink)
		XCTAssertFalse(cellModel.isUnseenNewsIndicatorVisible)
	}

	func testVaccinationHintForCompleteProtectionWithUnseenBoosterRule() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -150, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			boosterRule: .fake(
				identifier: "BR-ID-049",
				description: [
					Description(lang: "abc", desc: "Booster Rule Description.")
				]
			),
			isNewBoosterRule: true
		)

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 150 Tagen")
		XCTAssertEqual(cellModel.description, "Booster Rule Description. (BR-ID-049)")

		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
		XCTAssertTrue(cellModel.isUnseenNewsIndicatorVisible)
	}

	func testVaccinationHintForCompleteProtectionWithSeenBoosterRule() throws {
		let healthCertificate = try vaccinationCertificate(daysOffset: -1500, doseNumber: 2, totalSeriesOfDoses: 2)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			boosterRule: .fake(
				identifier: "BR-ID-062",
				description: [
					Description(lang: "DE", desc: "Another Booster Rule Description.")
				]
			),
			isNewBoosterRule: false
		)

		let cellModel = VaccinationHintCellModel(healthCertifiedPerson: healthCertifiedPerson)

		XCTAssertEqual(cellModel.title, "Impfstatus")
		XCTAssertEqual(cellModel.subtitle, "Letzte Impfung vor 1500 Tagen")
		XCTAssertEqual(cellModel.description, "Another Booster Rule Description. (BR-ID-062)")

		XCTAssertEqual(cellModel.faqLink?.string, "Mehr Informationen finden Sie in den FAQ.")
		XCTAssertFalse(cellModel.isUnseenNewsIndicatorVisible)
	}

}
