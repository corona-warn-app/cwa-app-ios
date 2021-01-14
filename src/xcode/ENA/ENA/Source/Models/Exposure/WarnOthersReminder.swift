//
// 🦠 Corona-Warn-App
//

import UIKit

/// The `WarnOthers` class  behaves as a facade and encaplsulate all relevant logic whether to schedule or not to schedule warn others notifications about a positiv test result.
/// So you only need to pass the result into `evaluateNotificationState(testResult: TestResult)` and all scheduling is managed.
///
/// Notification scheduling - the app will inform the user 2 times to warn others. These notifications only will get scheduled, if the user not yet has given consent to warn others.
/// WarnOthers always is related to one concrete test result, which always needs to be a positive one.
class WarnOthersReminder: WarnOthersRemindable {
	
	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Protocol WarnOthersRemindable

	var positiveTestResultWasShown: Bool {
		get {
			return store.positiveTestResultWasShown
		}
		set {
			store.positiveTestResultWasShown = newValue
		}
	}
	
	var isSubmissionConsentGiven: Bool {
		return store.isSubmissionConsentGiven
	}

	/// Notification timer in seconds for notification one
	var notificationOneTimeInterval: TimeInterval {
		get {
			return store.warnOthersNotificationOneTimer
		}
		set {
			store.warnOthersNotificationOneTimer = newValue
		}
	}

	/// Notification timer in seconds for notification two
	var notificationTwoTimeInterval: TimeInterval {
		get {
			return store.warnOthersNotificationTwoTimer
		}
		set {
			store.warnOthersNotificationTwoTimer = newValue
		}
	}

	/// This function takes a `TestResult` as parameter to evaluate, if possible notifications need to be scheduled for the warn others notification process.
	func evaluateShowingTestResult(_ testResult: TestResult) {
		// If incoming test restuls are others than positive, we don't deal with them
		guard testResult == .positive, !positiveTestResultWasShown else { return }
		
		// We are "clean" to go. So lock the door until result was removed
		positiveTestResultWasShown = true
		
		guard !isSubmissionConsentGiven else { return }
		
		scheduleNotifications()
	}
	
	func reset() {
		cancelNotifications()
		positiveTestResultWasShown = false
		Log.info("Warn others reminders have been reset")
	}
	
	/// In case the user has informed others about the positive result, this function should be called to reset possible pending 'warn others' notifications
	func cancelNotifications() {
		UNUserNotificationCenter.current().cancelWarnOthersNotification()
		Log.info("Warn others reminder: All notifications have been canceled")
	}
	
	// MARK: - Private

	private let store: Store
	
	private func scheduleNotifications() {
		UNUserNotificationCenter.current().scheduleWarnOthersNotifications(
			timeIntervalOne: TimeInterval(notificationOneTimeInterval),
			timeIntervalTwo: TimeInterval(notificationTwoTimeInterval)
		)
		Log.info("Warn others reminder: New notifications have been scheduled:  #1 \(store.warnOthersNotificationOneTimer)/ #2 \(store.warnOthersNotificationTwoTimer) seconds)")
	}
	
}
