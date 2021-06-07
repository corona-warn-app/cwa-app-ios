////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SimpleTextCellViewModelTests: CWATestCase {

	func testGIVEN_SimpleTextCellViewModel_THEN_AllValuesDidSetCorrect() {
		// GIVEN
		let simpleTextCellModel = SimpleTextCellViewModel(
			backgroundColor: .white,
			textColor: .red,
			textAlignment: .left,
			text: "das ist ein Testtext",
			attributedText: NSAttributedString(string: "das ist ein attributed Testtext"),
			topSpace: 100.0,
			font: .systemFont(ofSize: 12.0),
			borderColor: .green
		)

		// THEN
		XCTAssertEqual(simpleTextCellModel.backgroundColor, .white)
		XCTAssertEqual(simpleTextCellModel.textColor, .red)
		XCTAssertEqual(simpleTextCellModel.textAlignment, .left)
		XCTAssertEqual(simpleTextCellModel.text, "das ist ein Testtext")
		XCTAssertEqual(simpleTextCellModel.attributedText, NSAttributedString(string: "das ist ein attributed Testtext"))
		XCTAssertEqual(simpleTextCellModel.topSpace, 100.0)
		XCTAssertEqual(simpleTextCellModel.font, .systemFont(ofSize: 12.0))
		XCTAssertEqual(simpleTextCellModel.borderColor, .green)
	}

	func testGIVEN_SimpleTextCellViewModelWithMissingValues_THEN_AllValuesDidSetCorrect() {
		// GIVEN
		let simpleTextCellModel = SimpleTextCellViewModel(
			backgroundColor: .white,
			topSpace: 100.0,
			font: .systemFont(ofSize: 12.0),
			borderColor: .green
		)

		// THEN
		XCTAssertEqual(simpleTextCellModel.backgroundColor, .white)
		XCTAssertEqual(simpleTextCellModel.textAlignment, .center)
		XCTAssertEqual(simpleTextCellModel.topSpace, 100.0)
		XCTAssertEqual(simpleTextCellModel.font, .systemFont(ofSize: 12.0))
		XCTAssertEqual(simpleTextCellModel.borderColor, .green)
	}

}
