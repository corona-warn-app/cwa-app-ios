////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FooterViewControllerTests: CWATestCase {

	func testGIVEN_FooterViewControllerTests() {
		// GIVEN
		let model = FooterViewModel(primaryButtonName: "Button")
		let vc = FooterViewController(model)
		// THEN
		XCTAssertNotNil(vc)
	}
}
