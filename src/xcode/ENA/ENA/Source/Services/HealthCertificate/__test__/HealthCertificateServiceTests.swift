////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateServiceTests: XCTestCase {

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdated() throws {
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [],
			proofCertificate: nil
		)

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let service = HealthCertificateService(store: store)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let proofCertificate = try ProofCertificate(cborData: CBORData())

		healthCertifiedPerson.proofCertificate = proofCertificate

		XCTAssertEqual(store.healthCertifiedPersons.first?.proofCertificate, proofCertificate)

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

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

		healthCertifiedPerson.proofCertificate = try ProofCertificate(cborData: CBORData())

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

}
