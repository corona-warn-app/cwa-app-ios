import Foundation


/// Global flag if UI testing is enabled or not
var isUITesting: Bool {
	// defined in XCUIApplication.setDefaults()
	return ProcessInfo.processInfo.environment["XCUI"] == "YES"
}
