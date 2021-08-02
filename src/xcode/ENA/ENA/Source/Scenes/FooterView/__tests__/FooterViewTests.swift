////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FooterViewTests: CWATestCase {

	func testGIVEN_FooterViewTests() {
		// GIVEN
		let model = FooterViewModel(primaryButtonName: "Button")
		let view = FooterView(model)
		// THEN
		XCTAssertNotNil(view)
	}
}
