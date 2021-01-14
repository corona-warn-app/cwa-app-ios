//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

class WarnOthersReminderTests: XCTestCase {
	
	override func tearDown() {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		// To ensure we have no scheduled warn others notifications leftovers
		warnOthersReminder.reset()
	}
	
	func testWarnOthers_allVariablesAreInitial() throws {
		
		let store = MockTestStore()
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		let timerOneTime = WarnOthersNotificationsTimeInterval.intervalOne
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, timerOneTime, "Notification timeInterval one has not the intial value of \(timerOneTime)")
		
		let timerTwoTime = WarnOthersNotificationsTimeInterval.intervalTwo
		XCTAssertEqual(Double(warnOthersReminder.notificationTwoTimeInterval), timerTwoTime, "Notification timeInterval two has not the intial value of \(timerTwoTime)")
		
		XCTAssertFalse(warnOthersReminder.positiveTestResultWasShown, "Inital value of positiveTestResultWasShown should be 'false'")
		
	}
	
	func testWarnOthers_changedValuesShouldBeCorrect() throws {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		warnOthersReminder.evaluateShowingTestResult(.positive)
		XCTAssertTrue(warnOthersReminder.positiveTestResultWasShown, "Inital value of positiveTestResultWasShown should be 'true'")
		
		warnOthersReminder.notificationOneTimeInterval = TimeInterval(42)
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, TimeInterval(42), "Notification timeInterval one has not the intial value of '42'")
		
		warnOthersReminder.notificationTwoTimeInterval = TimeInterval(43)
		XCTAssertEqual(warnOthersReminder.notificationTwoTimeInterval, TimeInterval(43), "Notification timeInterval two has not the intial value of '43'")
		
		warnOthersReminder.reset()
		XCTAssertFalse(warnOthersReminder.positiveTestResultWasShown, "Inital value of positiveTestResultWasShown should be 'false'")
	}
	
	
	func testWarnOthers_SubmissionConsentGiven() throws {
		
		let store = MockTestStore()
		store.isSubmissionConsentGiven = true
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		XCTAssertTrue(warnOthersReminder.isSubmissionConsentGiven, "Submission consent given should be true")
		
	}
	
	func testWarnOthers_noSubmissionConsentGiven() throws {
		
		let store = MockTestStore()
		store.isSubmissionConsentGiven = false
		
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		XCTAssertFalse(warnOthersReminder.isSubmissionConsentGiven, "Submission consent given should be false")
		
	}
	
}
