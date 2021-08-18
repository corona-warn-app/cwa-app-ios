//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TanInputViewModelTests: CWATestCase {

	func testGIVEN_TitleAndDescription_WHEN_GettingTitleAndDescription_THEN_CorrectTitleAndDescriptionAreReturned() {
		// GIVEN
		let viewModel = TanInputViewModel(
			title: "Title",
			description: "Description",
			onPrimaryButtonTap: { _, _ in },
			givenTan: ""
		)

		// WHEN
		let title = viewModel.title
		let description = viewModel.description

		// THEN
		XCTAssertEqual(title, "Title")
		XCTAssertEqual(description, "Description")
	}

	func testGIVEN_ValidFormattedTanWithValidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChecksumIsValid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			title: "",
			description: "",
			onPrimaryButtonTap: { _, _ in },
			givenTan: "234567893D"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertTrue(isChecksumValid, "tan checksum is invalid")
	}

	func testGIVEN_ValidFormattedTanWithInvalidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChecksumIsInvalid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			title: "",
			description: "",
			onPrimaryButtonTap: { _, _ in },
			givenTan: "ZBYKEVDBNU"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertFalse(isChecksumValid, "tan checksum is valid")
	}

	func testGIVEN_wrongCharacterTanString_WHEN_isValidCheck_THEN_isInvalidChecksumIsInvalid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			title: "",
			description: "",
			onPrimaryButtonTap: { _, _ in },
			givenTan: "ZBYKEVDBNL"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertFalse(isChecksumValid, "tan checksum is valid")
	}

}
