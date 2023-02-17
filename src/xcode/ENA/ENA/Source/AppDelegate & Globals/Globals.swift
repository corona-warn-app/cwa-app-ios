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

/// Determines the CWA Hibernation State, beginning on 01.06.2023.
var isHibernationState: Bool {
	#if RELEASE

	var hibernationStartDateComponents = DateComponents()
	hibernationStartDateComponents.year = 2023
	hibernationStartDateComponents.month = 6
	hibernationStartDateComponents.day = 1
	hibernationStartDateComponents.hour = 0
	hibernationStartDateComponents.minute = 0
	hibernationStartDateComponents.second = 0
	hibernationStartDateComponents.timeZone = .utcTimeZone
	
	guard let hibernationStartDate = Calendar.current.date(from: hibernationStartDateComponents) else {
		fatalError("The hibernation start date couldn't be created.")
	}
	
	return Date() >= hibernationStartDate

	#else

	return true // to.do Dev Menu setting, see https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-14812
	
	#endif
}

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
