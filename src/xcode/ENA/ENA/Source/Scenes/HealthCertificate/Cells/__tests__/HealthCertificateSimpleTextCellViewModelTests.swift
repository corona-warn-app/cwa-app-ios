////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateSimpleTextCellViewModelTests: XCTestCase {

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
			boarderColor: .green,
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
		XCTAssertEqual(viewModel.boarderColor, .green)
		XCTAssertEqual(viewModel.accessibilityTraits, .header)
	}

}
