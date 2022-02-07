//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_TestResultTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "4a9ff5fa6b095ea108abf4e4507c1a5152739ea53fd7f916d8106ede91ed6ab3"
		let locator = Locator.testResult(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
