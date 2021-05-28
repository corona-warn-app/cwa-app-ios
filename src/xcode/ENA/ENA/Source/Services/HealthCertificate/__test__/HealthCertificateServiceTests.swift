//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateServiceTests: CWATestCase {

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdated() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(store: store)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let result = service.registerHealthCertificate(base45: HealthCertificate.mockBase45)

		switch result {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [HealthCertificate.mock()])
		case .failure:
			XCTFail("Registration should succeed")
		}

		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [HealthCertificate.mock()])

		subscription.cancel()
	}

}
