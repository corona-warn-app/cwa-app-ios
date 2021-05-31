////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateKeyValueCellViewModelTests: CWATestCase {

	func testGIVEN_OnlyKeyString_THEN_isNil() {
		// GIVEN
		let viewModel = HealthCertificateKeyValueCellViewModel(key: "Key", value: nil)

		// THEN
		XCTAssertNil(viewModel)
	}

	func testGIVEN_OnlyValueString_THEN_isNil() {
		// GIVEN
		let viewModel = HealthCertificateKeyValueCellViewModel(key: nil, value: "Value")

		// THEN
		XCTAssertNil(viewModel)
	}


	func testGIVEN_KeyAndValue_WHEN_InitViewModel_THEN_ValuesAreAsExpected() throws {
		// GIVEN
		let key = "Key"
		let value = "Value"

		// WHEN
		let viewModel = try XCTUnwrap(HealthCertificateKeyValueCellViewModel(key: key, value: value))

		// THEN
		XCTAssertEqual(viewModel.headlineFont, .enaFont(for: .body))
		XCTAssertEqual(viewModel.textFont, .enaFont(for: .subheadline))
		XCTAssertEqual(viewModel.headlineTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.textTextColor, .enaColor(for: .textPrimary2))

		XCTAssertEqual(viewModel.headline, key)
		XCTAssertEqual(viewModel.text, value)
		XCTAssertFalse(viewModel.isBottomSeparatorHidden)
		XCTAssertNil(viewModel.topSpace)
		XCTAssertNil(viewModel.bottomSpace)
	}

	func testGIVEN_KeyValueTopBottomSpaceHideSeperator_WHEN_InitViewModel_THEN_ValuesAreAsExpected() throws {
		// GIVEN
		let key = "Key"
		let value = "Value"

		// WHEN
		let viewModel = try XCTUnwrap(
			HealthCertificateKeyValueCellViewModel(
				key: key,
				value: value,
				isBottomSeparatorHidden: true,
				topSpace: 200.0,
				bottomSpace: 500.0
			))

		// THEN
		XCTAssertEqual(viewModel.headlineFont, .enaFont(for: .body))
		XCTAssertEqual(viewModel.textFont, .enaFont(for: .subheadline))
		XCTAssertEqual(viewModel.headlineTextColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.textTextColor, .enaColor(for: .textPrimary2))

		XCTAssertEqual(viewModel.headline, key)
		XCTAssertEqual(viewModel.text, value)
		XCTAssertTrue(viewModel.isBottomSeparatorHidden)
		XCTAssertEqual(viewModel.topSpace, 200.0)
		XCTAssertEqual(viewModel.bottomSpace, 500.0)
	}

}
