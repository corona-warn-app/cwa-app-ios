//
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

		let healthCertificate = HealthCertificate.mock()
		healthCertifiedPerson.healthCertificates = [healthCertificate]

		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [healthCertificate])

		subscription.cancel()
	}

}
