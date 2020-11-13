//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class DetectionModeTests: XCTestCase {
    func testThatDefaultModeIsManual() {
		XCTAssertEqual(DetectionMode.default, .manual)
    }

	func testThatDetectionModeCanBeCreatedFromTheBackgroundRefreshStatus() {
		XCTAssertEqual(DetectionMode.fromBackgroundStatus(.available), .automatic)
		XCTAssertEqual(DetectionMode.fromBackgroundStatus(.denied), .manual)
		XCTAssertEqual(DetectionMode.fromBackgroundStatus(.restricted), .manual)
	}
}
