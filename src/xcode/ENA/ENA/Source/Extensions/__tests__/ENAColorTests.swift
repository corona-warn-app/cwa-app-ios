//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ENAColorTests: CWATestCase {

	func testAvailableColors() {
		for style in ENAColor.allCases {
			XCTAssertNotNil(UIColor(enaColor: style), "ENAColor does not exist: \(style.rawValue)")
		}
	}

}
