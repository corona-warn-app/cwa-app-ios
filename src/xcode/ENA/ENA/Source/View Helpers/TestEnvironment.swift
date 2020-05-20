import UIKit

struct TestEnvironment {
	static let shared = TestEnvironment()
	let isUITesting = (ProcessInfo.processInfo.environment["XCUI"] == "YES")
	let isOnboarded = (ProcessInfo.processInfo.environment["isOnboarded"] == "YES")
}
