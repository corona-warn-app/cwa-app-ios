//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPersonBoosterTests: CWATestCase {

	private let biontechString = "EU/1/20/1528"
	private let modernaString = "EU/1/20/1507"
	private let astraZenecaString = "EU/1/21/1529"
	private let johnsonAndJohnson = "EU/1/20/1525"

	// MARK: - all booster states

	func testGIVEN_Certificates_WHEN_VaccinationEntryBionTechBooster_THEN_isCompleteBoosterVaccinationProtectionDateNotNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: biontechString,
									doseNumber: 3,
									totalSeriesOfDoses: 3,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNotNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryModernaBooster_THEN_isCompleteBoosterVaccinationProtectionDateNotNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: modernaString,
									doseNumber: 3,
									totalSeriesOfDoses: 3,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNotNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryAstraBooster_THEN_isCompleteBoosterVaccinationProtectionDateNotNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: astraZenecaString,
									doseNumber: 3,
									totalSeriesOfDoses: 3,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNotNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryJohnsonAndJohnson_THEN_isCompleteBoosterVaccinationProtectionDateNotNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: johnsonAndJohnson,
									doseNumber: 2,
									totalSeriesOfDoses: 2,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNotNil(completeBoosterVaccinationProtectionDate)
	}

	// MARK: - all no booster states

	func testGIVEN_Certificates_WHEN_VaccinationEntryBionTechBooster_THEN_isCompleteBoosterVaccinationProtectionDateIsNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: biontechString,
									doseNumber: 2,
									totalSeriesOfDoses: 32,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryModernaBooster_THEN_isCompleteBoosterVaccinationProtectionDateIsNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: modernaString,
									doseNumber: 2,
									totalSeriesOfDoses: 2,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryAstraBooster_THEN_isCompleteBoosterVaccinationProtectionDateIsNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: astraZenecaString,
									doseNumber: 2,
									totalSeriesOfDoses: 2,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNil(completeBoosterVaccinationProtectionDate)
	}

	func testGIVEN_Certificates_WHEN_VaccinationEntryJohnsonAndJohnson_THEN_isCompleteBoosterVaccinationProtectionDateIsNil() throws {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							vaccinationEntries: [
								VaccinationEntry.fake(
									vaccineMedicinalProduct: johnsonAndJohnson,
									doseNumber: 1,
									totalSeriesOfDoses: 1,
									dateOfVaccination: "2021-02-02"
								)
							]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		// WHEN
		let completeBoosterVaccinationProtectionDate = healthCertifiedPerson.completeBoosterVaccinationProtectionDate

		// THEN
		XCTAssertNil(completeBoosterVaccinationProtectionDate)
	}

}
