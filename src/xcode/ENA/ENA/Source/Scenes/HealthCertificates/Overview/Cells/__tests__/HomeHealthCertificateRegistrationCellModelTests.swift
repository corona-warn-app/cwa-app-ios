////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeHealthCertificateRegistrationCellModelTests: XCTestCase {

	func testGIVEN_HomeHealthCertificateRegistrationCellModel_THEN_InitIsAsExpected() {
	// GIVEN
	let viewModel = HomeHealthCertificateRegistrationCellModel()

	// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.VaccinationCertificateRegistration.title)
		XCTAssertEqual(viewModel.description, AppStrings.HealthCertificate.Overview.VaccinationCertificateRegistration.description)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateRegistrationCell)
	}

}
