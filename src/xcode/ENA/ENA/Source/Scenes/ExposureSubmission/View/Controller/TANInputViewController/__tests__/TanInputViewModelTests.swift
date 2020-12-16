////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TanInputViewModelTests: XCTestCase {

	func testGIVEN_ValidFormattedTanWithValidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChcksumIsValid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			presentInvalidTanAlert: { _, _  in },
			tanSuccessfullyTransferred: { },
			givenTan: "234567893D"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertTrue(isChecksumValid, "tan checksum is invalid")
	}

	func testGIVEN_ValidFormattedTanWithInvalidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChcksumIsInvalid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			presentInvalidTanAlert: { _, _  in },
			tanSuccessfullyTransferred: { },
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
			exposureSubmissionService: MockExposureSubmissionService(),
			presentInvalidTanAlert: { _, _  in },
			tanSuccessfullyTransferred: { },
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
