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
		let healthCertificate = HealthCertificate.mock(base45: HealthCertificateMocks.firstBase45Mock)

		let objectDidChangeExpectation = expectation(description: "objectDidChange publisher updated")
		// One update from the vaccination state, one from the most relevant certificate determination and one from extending the health certificate array itself
		objectDidChangeExpectation.expectedFulfillmentCount = 3

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

}
