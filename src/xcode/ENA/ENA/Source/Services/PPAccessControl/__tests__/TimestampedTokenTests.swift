////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TimestampedTokenTests: XCTestCase {

	func testGIVEN_TimestampedToken_THEN_EverythinIsSetCorrect() {
		// GIVEN
		let now = Date()
		let timestampedToken = TimestampedToken(token: "abCdE12", timestamp: now)

		// THEN
		XCTAssertEqual(timestampedToken.token, "abCdE12")
		XCTAssertEqual(timestampedToken.timestamp, now)
	}

}
