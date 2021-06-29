////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertifiedPersonCellModelTests: XCTestCase {

	func testGIVEN_healthCertifiedPerson_THEN_IsSetupCorrectly() throws {
		// GIVEN
		let healthCertificate1 = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1
			]
		)
		let viewModel = try XCTUnwrap(HealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson))

		guard case .partiallyVaccinated = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not partiallyVaccinated")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.covidTitle)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell)
	}

}
