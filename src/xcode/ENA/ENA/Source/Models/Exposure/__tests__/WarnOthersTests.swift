//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

class WarnOthersReminderTests: XCTestCase {
	
	private var store: SecureStore!
	
	override func setUpWithError() throws {
		store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment())
	}
	
	func testWarnOthers_allVariablesAreInitial() throws {
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		let timerOneTime = TimeInterval(WarnOthersNotificationsTimer.timerOneTime.rawValue)
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, timerOneTime, "Notification timer one has not the intial value of \(timerOneTime)")
		
		let timerTwoTime = TimeInterval(WarnOthersNotificationsTimer.timerTwoTime.rawValue)
		XCTAssertEqual(Double(warnOthersReminder.notificationTwoTimeInterval), timerTwoTime, "Notification timer two has not the intial value of \(timerTwoTime)")
		
		XCTAssertFalse(warnOthersReminder.hasPositiveTestResult, "Inital value of storedResult should be 'false'")
		
		warnOthersReminder.evaluateNotificationState(testResult: .positive)
		XCTAssertTrue(warnOthersReminder.hasPositiveTestResult, "Inital value of storedResult should be 'true'")
		
		warnOthersReminder.notificationOneTimeInterval = 42
		XCTAssertEqual(warnOthersReminder.notificationTwoTimeInterval, 42, "Notification timer one has not the intial value of '42'")
		
		warnOthersReminder.notificationTwoTimeInterval = 42
		XCTAssertEqual(warnOthersReminder.notificationTwoTimeInterval, 42, "Notification timer two has not the intial value of '42'")
		
		warnOthersReminder.reset()
		XCTAssertFalse(warnOthersReminder.hasPositiveTestResult, "Inital value of storedResult should be 'false'")
	}
}
