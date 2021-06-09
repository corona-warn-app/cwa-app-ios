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

		let service = HealthCertificateService(
			store: store,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let result = service.registerVaccinationCertificate(base45: HealthCertificate.mockBase45)

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

	func testRegisteringTestCertificate() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let base45Result = DigitalGreenCertificateFake.makeBase45Fake(
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			),
			and: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result else {
			XCTFail("Could not make fake base45 certificate")
			return
		}

		let registrationResult = service.registerHealthCertificate(base45: base45)

		switch registrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [try HealthCertificate(base45: base45)])
		case .failure:
			XCTFail("Registration should succeed")
		}

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [try HealthCertificate(base45: base45)])

		// Try to register same certificate twice
		let secondRegistrationResult = service.registerHealthCertificate(base45: base45)

		if case .failure(let error) = secondRegistrationResult, case .certificateAlreadyRegistered = error { } else {
			XCTFail("Double registration of the same certificate should fail")
		}

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [try HealthCertificate(base45: base45)])
	}

}
