//
// 🦠 Corona-Warn-App
//

import UIKit

/// Notification scheduling - the app will inform the user 2 times to warn others.
class WarnOthersReminder {
	
	// MARK: - Init

	init(
		store: WarnOthersTimeIntervalStoring,
		userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
	) {
		self.store = store
		self.userNotificationCenter = userNotificationCenter
	}

	// MARK: - Internal

	/// Notification timer in seconds for notification one
	var notificationOneTimeInterval: TimeInterval {
		get {
			return store.warnOthersNotificationOneTimeInterval
		}
		set {
			store.warnOthersNotificationOneTimeInterval = newValue
		}
	}

	/// Notification timer in seconds for notification two
	var notificationTwoTimeInterval: TimeInterval {
		get {
			return store.warnOthersNotificationTwoTimeInterval
		}
		set {
			store.warnOthersNotificationTwoTimeInterval = newValue
		}
	}

	/// This function takes a `CoronaTestType` as parameter to schedule warn others notifications for this test type
	func scheduleNotifications(for coronaTestType: CoronaTestType) {
		userNotificationCenter.scheduleWarnOthersNotifications(
			coronaTestType: coronaTestType,
			timeIntervalOne: TimeInterval(notificationOneTimeInterval),
			timeIntervalTwo: TimeInterval(notificationTwoTimeInterval)
		)
		Log.info("Warn others reminder: New notifications for type \(coronaTestType) have been scheduled:  #1 \(store.warnOthersNotificationOneTimeInterval)/ #2 \(store.warnOthersNotificationTwoTimeInterval) seconds)")
	}

	/// In case the user has informed others about the positive result, this function should be called to reset possible pending 'warn others' notifications
	func cancelNotifications(for coronaTestType: CoronaTestType) {
		userNotificationCenter.cancelWarnOthersNotification(coronaTestType: coronaTestType)
		Log.info("Warn others reminder: Notifications for type \(coronaTestType) have been canceled")
	}

	func reset() {
		for coronaTestType in CoronaTestType.allCases {
			cancelNotifications(for: coronaTestType)
		}
	}
	
	// MARK: - Private

	private var store: WarnOthersTimeIntervalStoring
	private var userNotificationCenter: UserNotificationCenter

}
