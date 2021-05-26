////
// 🦠 Corona-Warn-App
//

import XCTest

class CWATestCase: XCTestCase {

	override func setUpWithError() throws {
		try super.setUpWithError()

		// swiftlint:disable:next force_unwrapping
		try XCTSkipIf(testRun!.totalFailureCount > 0, "Fast fail ☠️")
	}

}
