//
// 🦠 Corona-Warn-App
//

import UserNotifications

protocol DeadmanNotificationManageable {
	func scheduleDeadmanNotificationIfNeeded()
	func resetDeadmanNotification()
}

struct DeadmanNotificationManager: DeadmanNotificationManageable {

	// MARK: - Init

	init(
		userNotificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
	) {
		self.userNotificationCenter = userNotificationCenter
	}

	// MARK: - Internal

	static let deadmanNotificationIdentifier = (Bundle.main.bundleIdentifier ?? "") + ".notifications.cwa-deadman"
	
	/// Schedules a local notification to fire 36 hours from now, if there isn´t a notification already scheduled
	func scheduleDeadmanNotificationIfNeeded() {
		/// Check if Deadman Notification is already scheduled
		///
		let numberOfHoursUntilEOL: Int
		if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil  {
			// set numberOfHoursUntilEOL for unit testing as store is not initilized in the CWAHibernationProvider
			numberOfHoursUntilEOL = 40
		} else {
			numberOfHoursUntilEOL = Calendar.current.dateComponents([.hour], from: Date(), to: CWAHibernationProvider.shared.hibernationStartDateForBuild).hour ?? 0
		}
		Log.debug("numberOfHours Until EOL: \(numberOfHoursUntilEOL).")
		userNotificationCenter.getPendingNotificationRequests { notificationRequests in
			if notificationRequests.contains(where: {
				 $0.identifier == Self.deadmanNotificationIdentifier
			}) {
				// A deadman notification is scheduled in 36 hours or less.
				// check if we reach EOL in 36 hours or less then cancel the pending deadman notification.
				if  numberOfHoursUntilEOL < 36 {
					Log.debug("canceling scheduled deadman notifications as it will be fired during EOL")
					cancelDeadmanNotification()
				}
				/// Deadman Notification already setup -> return
				return
			} else {
				// check if we reach EOL will be reached in 36 hours or less then we do NOT schedule a deadman notification.
				guard numberOfHoursUntilEOL < 36 else {
					Log.debug("EOL will be reached in \(numberOfHoursUntilEOL) hours, so no need to schedule a deadman notification.")
					return
				}
				/// No Deadman Notification setup, continue to setup a new one
				let content = UNMutableNotificationContent()
				content.title = AppStrings.Common.deadmanAlertTitle
				content.body = AppStrings.Common.deadmanAlertBody
				content.sound = .default
				
				let trigger = UNTimeIntervalNotificationTrigger(
					timeInterval: 36 * 60 * 60,
					repeats: false
				)
				
				let request = UNNotificationRequest(
					identifier: Self.deadmanNotificationIdentifier,
					content: content,
					trigger: trigger
				)
				
				userNotificationCenter.add(request) { error in
					if error != nil {
						Log.error("Deadman notification could not be scheduled.")
					}
				}
			}
		}
	}
	
	/// Reset the Deadman Notification, should be called after a successful risk-calculation.
	func resetDeadmanNotification() {
		cancelDeadmanNotification()
		if !CWAHibernationProvider.shared.isHibernationState {
			scheduleDeadmanNotificationIfNeeded()
		}
	}
	
	// MARK: - Private

	private let userNotificationCenter: UserNotificationCenter

	/// Cancels the Deadman Notification
	private func cancelDeadmanNotification() {
		userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.deadmanNotificationIdentifier])
	}

}
