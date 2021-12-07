//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPersonTests: CWATestCase {

	func testHealthCertifiedPersonObjectDidChangeTriggered() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		let healthCertificate = try vaccinationCertificate(type: .seriesCompleting, ageInDays: 15)

		let objectDidChangeExpectation = expectation(description: "objectDidChange publisher updated")
		// One update from the vaccination state, one from the admission state, one from the most relevant certificate determination and one from extending the health certificate array itself
		objectDidChangeExpectation.expectedFulfillmentCount = 4

		let subscription = healthCertifiedPerson.objectDidChange
			.sink {
				XCTAssertEqual($0.healthCertificates, [healthCertificate])
				objectDidChangeExpectation.fulfill()
			}

		healthCertifiedPerson.healthCertificates = [healthCertificate]

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

	func testSorting() throws {
		let healthCertifiedPerson1 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "B"
							),
							testEntries: [TestEntry.fake()]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		let healthCertifiedPerson2 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try base45Fake(
						from: DigitalCovidCertificate.fake(
							name: Name.fake(
								familyName: "A", givenName: "A"
							),
							vaccinationEntries: [VaccinationEntry.fake()]
						)
					)
				)
			],
			isPreferredPerson: false
		)

		XCTAssertEqual(
			[healthCertifiedPerson1, healthCertifiedPerson2].sorted(),
			[healthCertifiedPerson2, healthCertifiedPerson1]
		)

		healthCertifiedPerson1.isPreferredPerson = true

		XCTAssertEqual(
			[healthCertifiedPerson1, healthCertifiedPerson2].sorted(),
			[healthCertifiedPerson1, healthCertifiedPerson2]
		)
	}

	func testGIVEN_MedicalProductTyeString_WHEN_CreateEnum_THEN_isCorrectType() {
		// GIVEN
		let biontechString = "EU/1/20/1528"
		let modernaString = "EU/1/20/1507"
		let astraZenecaString = "EU/1/21/1529"
		let unknownString = "EU/1/19/1501"

		// WHEN
		let biontechProductType = VaccinationProductType(value: biontechString)
		let modernaProductType = VaccinationProductType(value: modernaString)
		let astraZenecaProductType = VaccinationProductType(value: astraZenecaString)
		let otherProductType = VaccinationProductType(value: unknownString)

		let biontechProductType2 = VaccinationProductType(value: biontechString.lowercased())
		let modernaProductType2 = VaccinationProductType(value: modernaString.lowercased())
		let astraZenecaProductType2 = VaccinationProductType(value: astraZenecaString.lowercased())
		let otherProductType2 = VaccinationProductType(value: unknownString.lowercased())

		// THEN
		XCTAssertEqual(biontechProductType, .biontech)
		XCTAssertEqual(modernaProductType, .moderna)
		XCTAssertEqual(astraZenecaProductType, .astraZeneca)
		XCTAssertEqual(otherProductType, .other)

		XCTAssertEqual(biontechProductType2, .biontech)
		XCTAssertEqual(modernaProductType2, .moderna)
		XCTAssertEqual(astraZenecaProductType2, .astraZeneca)
		XCTAssertEqual(otherProductType2, .other)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateBiontec_THEN_isNotNil() throws {
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
									vaccineMedicinalProduct: "EU/1/20/1528",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNotNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateModerna_THEN_isNotNil() throws {
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
									vaccineMedicinalProduct: "EU/1/20/1507",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNotNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateAstraZenica_THEN_isNotNil() throws {
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
									vaccineMedicinalProduct: "EU/1/21/1529",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNotNil(recoveredVaccinationCertificate)
	}


	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateBiontec2Doses_THEN_isNil() throws {
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
									vaccineMedicinalProduct: "EU/1/20/1528",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateModerna2Doses_THEN_isNil() throws {
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
									vaccineMedicinalProduct: "EU/1/20/1507",
									doseNumber: 1,
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateAstraZenica2Doses_THEN_isNil() throws {
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
									vaccineMedicinalProduct: "EU/1/21/1529",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_Certificates_WHEN_getRecoveredVaccinationCertificateUnknonw_THEN_isNil() throws {
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
									vaccineMedicinalProduct: "EU/1/20/1509",
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
		let recoveredVaccinationCertificate = healthCertifiedPerson.recoveredVaccinationCertificate

		// THEN
		XCTAssertNil(recoveredVaccinationCertificate)
	}

	func testGIVEN_PersonWithNewBoosterRuleAndCertificates_WHEN_EncodingAndDecoding_THEN_DataIsStillCorrect() throws {
		let firstHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
					from: DigitalCovidCertificate.fake(vaccinationEntries: [.fake()]
				)
			),
			didShowInvalidNotification: false,
			isNew: false,
			isValidityStateNew: false
		)

		let secondHealthCertificate = try HealthCertificate(
			base45: try base45Fake(
					from: DigitalCovidCertificate.fake(vaccinationEntries: [.fake()]
				)
			),
			didShowInvalidNotification: true,
			isNew: true,
			isValidityStateNew: true
		)

		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstHealthCertificate, secondHealthCertificate],
			isPreferredPerson: true,
			boosterRule: .fake(identifier: "Booster Rule Identifier 0815"),
			isNewBoosterRule: true
		)

		// WHEN
		let jsonData = try JSONEncoder().encode(healthCertifiedPerson)
		let decodedHealthCertifiedPerson = try JSONDecoder().decode(HealthCertifiedPerson.self, from: jsonData)

		// THEN
		XCTAssertEqual(decodedHealthCertifiedPerson, healthCertifiedPerson)
	}

}
