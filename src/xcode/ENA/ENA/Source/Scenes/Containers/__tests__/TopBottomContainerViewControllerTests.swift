////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class TopBottomContainerViewControllerTests: CWATestCase {
	
	func testInit() {
		let top = UIViewController()
		let model = FooterViewModel(primaryButtonName: "Button")
		let bottom = FooterView(model)
		XCTAssertNotNil(bottom)
		let vc = TopBottomContainerViewController(topController: top, bottomView: bottom)
		XCTAssertNotNil(vc)
	}
}
