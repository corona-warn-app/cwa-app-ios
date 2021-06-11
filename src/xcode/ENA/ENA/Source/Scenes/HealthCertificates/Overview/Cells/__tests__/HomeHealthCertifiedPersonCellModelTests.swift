////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeHealthCertifiedPersonCellModelTests: XCTestCase {

	func testGIVEN_completelyProtectedCertifiedPerson_THEN_IsSetupCorrectly() {
		// GIVEN
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [HealthCertificate.mock()])
		let viewModel = HomeHealthCertifiedPersonCellModel(healthCertifiedPerson: healthCertifiedPerson)

		guard case let .completelyProtected(expirationDate) = healthCertifiedPerson.vaccinationState else {
			XCTFail("Not completelyProtected")
			return
		}

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.VaccinationCertificate.title)
		XCTAssertEqual(viewModel.backgroundGradientType, healthCertifiedPerson.vaccinationState.gradientType)
		XCTAssertEqual(viewModel.name, healthCertifiedPerson.name?.fullName)
		XCTAssertEqual(viewModel.backgroundImage, UIImage(named: "VaccinationCertificate_CompletelyProtected_Background"))
		XCTAssertEqual(viewModel.iconImage, UIImage(named: "VaccinationCertificate_CompletelyProtected_Icon"))
		XCTAssertEqual(viewModel.description, String(
						format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.vaccinationValidUntil,
						DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none
						))
		)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell)
	}

}
