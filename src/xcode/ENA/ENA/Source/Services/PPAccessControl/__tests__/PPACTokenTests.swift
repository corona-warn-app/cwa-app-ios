////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPACTokenTests: CWATestCase {
	
	func testGIVEN_PPACToken_THEN_EverythinIsSetCorrect() {
		// GIVEN
		let ppacToken = PPACToken(
			apiToken: "12345",
			previousApiToken: "23456",
			deviceToken: "device")
		
		// THEN
		XCTAssertEqual(ppacToken.apiToken, "12345")
		XCTAssertEqual(ppacToken.deviceToken, "device")
	}
	
}
