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
		let healthCertificate = HealthCertificate.mock(base45: HealthCertificate.firstBase45Mock)

		let objectDidChangeExpectation = expectation(description: "objectDidChange publisher updated")

		let subscription = healthCertifiedPerson.objectDidChange
			.sink {
				XCTAssertEqual($0.healthCertificates, [healthCertificate])
				objectDidChangeExpectation.fulfill()
			}

		healthCertifiedPerson.healthCertificates = [healthCertificate]

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

}
