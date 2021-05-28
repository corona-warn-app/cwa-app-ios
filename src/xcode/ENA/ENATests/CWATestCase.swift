////
// 🦠 Corona-Warn-App
//

import XCTest


class CWATestCase: XCTestCase {

	override func setUpWithError() throws {
		try super.setUpWithError()

		continueAfterFailure = false

		// swiftlint:disable:next force_unwrapping
		try XCTSkipIf(testRun!.totalFailureCount > 0, "Fast fail \(self.testRun?.test.name ?? "")")
	}

}
