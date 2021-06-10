////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestCertificateInfoCellModelTests: XCTestCase {

	func testGIVEN_TestCertificateInfoCellModel_THEN_InitIsAsExpected() {
	// GIVEN
	let viewModel = TestCertificateInfoCellModel()

	// THEN
		XCTAssertEqual(viewModel.title, AppStrings.HealthCertificate.Overview.TestCertificateInfo.title)
		XCTAssertEqual(viewModel.description, AppStrings.HealthCertificate.Overview.TestCertificateInfo.description)
		XCTAssertEqual(viewModel.accessibilityIdentifier, AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateInfoCell)
	}

}
