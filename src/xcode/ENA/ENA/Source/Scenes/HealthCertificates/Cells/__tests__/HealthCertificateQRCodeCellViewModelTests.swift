////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateQRCodeCellViewModelTests: XCTestCase {

	func testGIVEN_HealthCertificateQRCodeCellViewModel_THEN_IsInitCorrect() throws {
		// GIVEN
		let viewModel = HealthCertificateQRCodeCellViewModel(
			healthCertificate: HealthCertificate.mock(),
			accessibilityText: nil
		)

		// THEN
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(viewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(viewModel.certificate, "Impfzertifikat 2 von 2")
		XCTAssertEqual(viewModel.validity, "Geimpft 02.02.2021 - gültig bis 03.06.2021")
		XCTAssertNil(viewModel.accessibilityText)
	}

}
