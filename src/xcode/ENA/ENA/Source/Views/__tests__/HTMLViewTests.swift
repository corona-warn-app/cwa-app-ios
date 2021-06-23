////
// 🦠 Corona-Warn-App
//

import XCTest
import WebKit
@testable import ENA

class HTMLViewTests: XCTestCase {

	func testInitializers() throws {
		let simple = HTMLView()
		XCTAssertFalse(simple.scrollView.isScrollEnabled)

		let config = WKWebViewConfiguration()
		config.preferences.javaScriptEnabled = false
		let configuredView = HTMLView(frame: .zero, configuration: config)
		XCTAssertFalse(configuredView.scrollView.isScrollEnabled)
	}

}
