////
// 🦠 Corona-Warn-App
//

import XCTest

/// Indicator for CI-triggered tests. If `false` you are running it most likely locally.
var isCI: Bool {
	return ProcessInfo.processInfo.environment["CI"] == "YES"
}

class CWATestCase: XCTestCase {

	override func tearDownWithError() throws {
		try super.tearDownWithError()

		if isCI, testRun!.totalFailureCount > 0 {
			let pid = ProcessInfo.processInfo.processIdentifier
			try "\(pid)".write(toFile: ".fail", atomically: true, encoding: .utf8)
		}
	}

}
