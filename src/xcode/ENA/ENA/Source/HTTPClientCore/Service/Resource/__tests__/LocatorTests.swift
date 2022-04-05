//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class LocatorTests: XCTestCase {
	
	func testUniqueIdentifier() {
		let locator = Locator(endpoint: .distribution, paths: ["path1", "path2"], method: .get)
		XCTAssertEqual(locator.uniqueIdentifier, "26e8601ff1ae54c1a8571f17efa0c52b9f9aa83635214b3e51e899b5ccb17d06")
	}
}
