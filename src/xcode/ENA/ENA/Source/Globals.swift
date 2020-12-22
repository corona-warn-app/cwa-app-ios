//
// 🦠 Corona-Warn-App
//

import Foundation


/// Global flag if UI testing is enabled or not
var isUITesting: Bool {
	// defined in XCUIApplication.setDefaults()
	return ProcessInfo.processInfo.environment["XCUI"] == "YES"
}

/// Running fastlane's snapshot or not
var isScreenshotMode: Bool {
	return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
}
