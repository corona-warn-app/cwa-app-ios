//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RevocationProviderTests: CWATestCase {

	func testGIVEN_base64_WHEN_ToHexString_THEN_ResultIsValid() {
		// GIVEN
		let base64 = "yLHLNvSl428="

		// WHEN
		let hexString = Data(base64Encoded: base64)?.toHexString() ?? ""

		// THEN
		XCTAssertEqual(hexString, "c8b1cb36f4a5e36f")
	}

	func testGIVEN_base64_WHEN_HexEncodedString_THEN_ResultIsValid() {
		// GIVEN
		let base64 = "yLHLNvSl428="

		// WHEN
		let hexString = Data(base64Encoded: base64)?.hexEncodedString() ?? ""

		// THEN
		XCTAssertEqual(hexString, "c8b1cb36f4a5e36f".uppercased())
	}

}
