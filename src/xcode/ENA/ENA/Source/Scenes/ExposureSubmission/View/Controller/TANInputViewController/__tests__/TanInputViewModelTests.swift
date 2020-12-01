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
			presentInvalidTanAlert: { _ in },
			presentTestResultScreen: { }
		)

		let tanToValidate = "234567893D"
		/* use original tanView to compare results here */
		let tanView = ENATanInput()
		tanView.awakeFromNib()
		tanView.insertText(tanToValidate)

		//WHEN
		let isValid = viewModel.isValid(tanToValidate)
		let isChecksumValid = viewModel.isChecksumValid(tanToValidate)

		//THEN
		XCTAssertEqual(isValid, tanView.isValid)
		XCTAssertEqual(isChecksumValid, tanView.isChecksumValid)

		XCTAssertTrue(isValid)
		XCTAssertTrue(isChecksumValid)
	}

	func testGIVEN_ValidFormattedTanWithInvalidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChcksumIsInvalid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			presentInvalidTanAlert: { _ in },
			presentTestResultScreen: { }
		)

		let tanToValidate = "ZBYKEVDBNU"
		/* use original tanView to compare results here */
		let tanView = ENATanInput()
		tanView.awakeFromNib()
		tanView.insertText(tanToValidate)

		//WHEN
		let isValid = viewModel.isValid(tanToValidate)
		let isChecksumValid = viewModel.isChecksumValid(tanToValidate)

		//THEN
		XCTAssertEqual(isValid, tanView.isValid)
		XCTAssertEqual(isChecksumValid, tanView.isChecksumValid)

		XCTAssertTrue(isValid)
		XCTAssertFalse(isChecksumValid)
	}

	func testGIVEN_wrongCharacterTanString_WHEN_isValidCheck_THEN_isInvalidChecksumIsInvalid() {
		// GIVEN
		let viewModel = TanInputViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			presentInvalidTanAlert: { _ in },
			presentTestResultScreen: { }
		)

		let tanToValidate = "ZBYKEVDBNL"
		/* use original tanView to compare results here */
		let tanView = ENATanInput()
		tanView.awakeFromNib()
		tanView.insertText(tanToValidate)

		//WHEN
		let isValid = viewModel.isValid(tanToValidate)
		let isChecksumValid = viewModel.isChecksumValid(tanToValidate)

		//THEN
		XCTAssertEqual(isValid, tanView.isValid)
		XCTAssertEqual(isChecksumValid, tanView.isChecksumValid)

		XCTAssertTrue(isValid)
		XCTAssertFalse(isChecksumValid)
	}



}
