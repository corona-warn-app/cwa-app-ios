////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class HealthCertificateServiceTests: XCTestCase {

	func testHealthCertifiedPersonsPublisherTriggered() throws {
		let service = HealthCertificateService(store: MockTestStore())

		let healthCertifiedPerson = HealthCertifiedPerson(
			proofCertificate: nil,
			healthCertificates: []
		)

		service.healthCertifiedPersons = [healthCertifiedPerson]

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.$healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		service.healthCertifiedPersons = []

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

	func testHealthCertifiedPersonObjectWillChangeTriggered() throws {
		let service = HealthCertificateService(store: MockTestStore())

		let healthCertifiedPerson = HealthCertifiedPerson(
			proofCertificate: nil,
			healthCertificates: []
		)

		service.healthCertifiedPersons = [healthCertifiedPerson]

		let objectWillChangeExpectation = expectation(description: "objectWillChange publisher updated")

		let subscription = healthCertifiedPerson.objectWillChange
			.sink { _ in
				objectWillChangeExpectation.fulfill()
			}

		healthCertifiedPerson.proofCertificate = ProofCertificate(cborRepresentation: Data(), expirationDate: Date())

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

}
