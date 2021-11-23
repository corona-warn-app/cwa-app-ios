//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TicketValidationResultCellModelTests: XCTestCase {

	func testGIVEN_PassedResult_WHEN_GettingIconImage_THEN_NilIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = nil

		let model = TicketValidationResultCellModel(
			validationResultItem: .fake(result: .passed)
		)

		// WHEN
		let icon = model.iconImage

		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}

	func testGIVEN_OpenResult_WHEN_GettingIconImage_THEN_OpenImageIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Open")

		let model = TicketValidationResultCellModel(
			validationResultItem: .fake(result: .open)
		)

		// WHEN
		let icon = model.iconImage

		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}

	func testGIVEN_FailedResult_WHEN_GettingIconImage_THEN_FailedImageIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")

		let model = TicketValidationResultCellModel(
			validationResultItem: .fake(result: .failed)
		)

		// WHEN
		let icon = model.iconImage

		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}

	func testWHEN_GettingItemDetails_THEN_ResultItemDetailsAreReturned() throws {
		// GIVEN
		let model = TicketValidationResultCellModel(
			validationResultItem: .fake(details: "validationResultItemDetails")
		)

		// WHEN
		let itemDetails = model.itemDetails

		// THEN
		XCTAssertEqual(itemDetails, "validationResultItemDetails")
	}

	func testWHEN_GettingKeyValueAttributedString_THEN_HeadlineAndRuleIdAreReturned() throws {
		// GIVEN
		let model = TicketValidationResultCellModel(
			validationResultItem: .fake(identifier: "itemIdentifier")
		)

		// WHEN
		let keyValueString = model.keyValueAttributedString.string

		// THEN
		XCTAssertEqual(keyValueString, "Regel-ID / Rule ID\nitemIdentifier")
	}

}
