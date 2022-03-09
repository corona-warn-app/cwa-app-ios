//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit
import class CertLogic.Rule

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
		let boosterRule = Rule.fake(identifier: "Booster Rule Identifier 0815")
		let dccWallet = DCCWalletInfo.fake()

		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [firstHealthCertificate, secondHealthCertificate],
			isPreferredPerson: true,
			dccWalletInfo: dccWallet,
			mostRecentWalletInfoUpdateFailed: true,
			boosterRule: boosterRule,
			isNewBoosterRule: true
		)

		// WHEN
		let jsonData = try JSONEncoder().encode(healthCertifiedPerson)
		let decodedHealthCertifiedPerson = try JSONDecoder().decode(HealthCertifiedPerson.self, from: jsonData)

		// THEN
		XCTAssertTrue(decodedHealthCertifiedPerson.isPreferredPerson)
		XCTAssertTrue(decodedHealthCertifiedPerson.isNewBoosterRule)
		XCTAssertEqual(decodedHealthCertifiedPerson.boosterRule, boosterRule)
		XCTAssertEqual(decodedHealthCertifiedPerson.dccWalletInfo, dccWallet)
		XCTAssertTrue(decodedHealthCertifiedPerson.mostRecentWalletInfoUpdateFailed)
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.base45 }, [firstHealthCertificate, secondHealthCertificate].map { $0.base45 })
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.validityState }, [firstHealthCertificate, secondHealthCertificate].map { $0.validityState })
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.isNew }, [firstHealthCertificate, secondHealthCertificate].map { $0.isNew })
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.isValidityStateNew }, [firstHealthCertificate, secondHealthCertificate].map { $0.isValidityStateNew })
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.didShowInvalidNotification }, [firstHealthCertificate, secondHealthCertificate].map { $0.didShowInvalidNotification })
		XCTAssertEqual(decodedHealthCertifiedPerson.healthCertificates.map { $0.didShowBlockedNotification }, [firstHealthCertificate, secondHealthCertificate].map { $0.didShowBlockedNotification })
	}

}
