//
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG

/// Global flag if UI testing is enabled or not
var isUITesting: Bool {
	// defined in XCUIApplication.setDefaults()
	return ProcessInfo.processInfo.environment["XCUI"] == "YES"
}

/// Running fastlane's snapshot or not
var isScreenshotMode: Bool {
	return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
}

#endif

/// Unconditionally logs, prints a given message and stops execution.
///
/// This 'catches' fatal errors by logging them first as errors… and then failing gloriously.
///
/// - Parameters:
///   - message: The string to print. The default is an empty string.
///   - file: The file name to print with `message`. The default is the file
///     where `fatalError(_:file:line:)` is called.
///   - line: The line number to print along with `message`. The default is the
///     line number where `fatalError(_:file:line:)` is called.
public func fatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
	Log.error("💥 Fatal Error: \(message())", log: .default, error: nil)
	return Swift.fatalError(message())
}
