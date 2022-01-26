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
		let healthCertificate = try vaccinationCertificate(type: .seriesCompletingOrBooster, ageInDays: 15)

		let objectDidChangeExpectation = expectation(description: "objectDidChange publisher updated")

		let subscription = healthCertifiedPerson.objectDidChange
			.sink {
				XCTAssertEqual($0.healthCertificates, [healthCertificate])
				objectDidChangeExpectation.fulfill()
			}

		healthCertifiedPerson.healthCertificates = [healthCertificate]

		waitForExpectations(timeout: .short)

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
