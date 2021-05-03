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
		let store = MockTestStore()
		let service = HealthCertificateService(store: store)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [],
			proofCertificate: nil
		)

		service.healthCertifiedPersons = [healthCertifiedPerson]

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.$healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let json = try JSONEncoder().encode(ProofCertificateResponse(expirationDate: Date()))

		let proofCertificate = try ProofCertificate(representations: CertificateRepresentations(base45: "", cbor: Data(), json: json))

		healthCertifiedPerson.proofCertificate = proofCertificate

		XCTAssertEqual(store.healthCertifiedPersons.first?.proofCertificate, proofCertificate)

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

	func testHealthCertifiedPersonObjectWillChangeTriggered() throws {
		let service = HealthCertificateService(store: MockTestStore())

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [],
			proofCertificate: nil
		)

		service.healthCertifiedPersons = [healthCertifiedPerson]

		let objectWillChangeExpectation = expectation(description: "objectWillChange publisher updated")

		let subscription = healthCertifiedPerson.objectWillChange
			.sink {
				objectWillChangeExpectation.fulfill()
			}

		let json = try JSONEncoder().encode(ProofCertificateResponse(expirationDate: Date()))
		healthCertifiedPerson.proofCertificate = try ProofCertificate(representations: CertificateRepresentations(base45: "", cbor: Data(), json: json))

		waitForExpectations(timeout: 5)

		subscription.cancel()
	}

}
