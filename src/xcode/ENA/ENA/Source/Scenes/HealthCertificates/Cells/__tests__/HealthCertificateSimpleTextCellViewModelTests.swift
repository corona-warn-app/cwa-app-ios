////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateSimpleTextCellViewModelTests: CWATestCase {

	func testGIVEN_ViewModel_THEN_InitIsCorrect() {
		// GIVEN
		let viewModel = HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .red,
			textColor: .blue,
			textAlignment: .center,
			text: "Testtext",
			attributedText: NSAttributedString(string: "Testtext attributed"),
			topSpace: 100.0,
			font: .systemFont(ofSize: 14.0),
			borderColor: .green,
			accessibilityTraits: .header
		)

	// THEN
		XCTAssertEqual(viewModel.backgroundColor, .red)
		XCTAssertEqual(viewModel.textColor, .blue)
		XCTAssertEqual(viewModel.textAlignment, .center)
		XCTAssertEqual(viewModel.text, "Testtext")
		XCTAssertEqual(viewModel.attributedText, NSAttributedString(string: "Testtext attributed"))
		XCTAssertEqual(viewModel.topSpace, 100.0)
		XCTAssertEqual(viewModel.font, .systemFont(ofSize: 14.0))
		XCTAssertEqual(viewModel.borderColor, .green)
		XCTAssertEqual(viewModel.accessibilityTraits, .header)
	}

}
