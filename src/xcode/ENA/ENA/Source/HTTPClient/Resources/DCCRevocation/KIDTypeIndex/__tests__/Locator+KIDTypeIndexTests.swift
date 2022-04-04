//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_KidTypeIndexTests: XCTestCase {
	
	func test_KidAndTypeAreConcatenated() {
		let kidTypeIndexLocator = Locator(kid: "SomeKid", hashType: "SomeType")
		XCTAssertEqual(
			kidTypeIndexLocator.paths,
			["version", "v1", "dcc-rl", "SomeKidSomeType", "index"]
		)
	}
}
