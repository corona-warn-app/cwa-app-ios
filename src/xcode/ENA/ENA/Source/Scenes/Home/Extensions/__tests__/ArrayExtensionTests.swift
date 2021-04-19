////
// 🦠 Corona-Warn-App
//

import XCTest

class ArrayExtensionTests: XCTestCase {

    func testSafeSubscript() throws {
        let list = [0, 1, 2]

		for i in 0..<list.count {
			XCTAssertNotNil(list[safe: i])
		}

		XCTAssertNil(list[safe: -1])
		XCTAssertNil(list[safe: 3])
    }

}
