//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertifiedPersonTests: XCTestCase {

	func testHealthCertifiedPersonObjectWillChangeTriggered() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [],
			proofCertificate: nil
		)

		let objectWillChangeExpectation = expectation(description: "objectWillChange publisher updated")

		let subscription = healthCertifiedPerson.objectWillChange
			.sink {
				objectWillChangeExpectation.fulfill()
			}

		let healthCertificate = HealthCertificate.mock()
		healthCertifiedPerson.healthCertificates = [healthCertificate]

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

}
