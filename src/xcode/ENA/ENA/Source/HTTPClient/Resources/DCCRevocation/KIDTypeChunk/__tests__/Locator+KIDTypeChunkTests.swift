//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_KidTypeChunkTests: XCTestCase {
	
	func test_KidAndTypeAreConcatenated() {
		let kidTypeIndexLocator = Locator(
			kid: "SomeKid",
			hashType: "SomeType",
			x: "x",
			y: "y"
		)
		XCTAssertEqual(
			kidTypeIndexLocator.paths,
			["version", "v1", "dcc-rl", "SomeKidSomeType", "x", "y", "chunk"]
		)
	}
}
