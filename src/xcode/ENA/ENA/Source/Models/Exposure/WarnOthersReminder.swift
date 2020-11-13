//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit

/// The `WarnOthers` class  behaves as a facade and encaplsulate all relevant logic whether to schedule or not to schedule warn others notifications about a positiv test result.
/// So you only need to pass the result into `evaluateNotificationState(testResult: TestResult)` and all scheduling is managed.
/// Notification scheduling - the app will inform the user 2 times to warn others.
/// WarnOthers always is related to one concrete test result, which always needs to be a positive one.
class WarnOthersReminder: WarnOthersRemindable {
	
	// MARK: - Init

	init(store: Store) {
		self.store = store
		self.hasPositiveTestResult = store.warnOthersHasActiveTestResult
	}

	// MARK: - Protocol WarnOthersRemindable

	var hasPositiveTestResult: Bool {
		get {
			return store.warnOthersHasActiveTestResult
		}
		set {
			store.warnOthersHasActiveTestResult = newValue
		}
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
	func evaluateNotificationState(testResult: TestResult) {
		
		// If incoming test restuls are others than positive, we don't deal with them
		guard testResult == .positive, hasPositiveTestResult == false else { return }
		
		// We are "clean" to go. So lock the door until result was removed
		hasPositiveTestResult = true
		
		scheduleNotifications()
	}
	
	func reset() {
		cancelNotifications()
		hasPositiveTestResult = false
		Log.info("Warn others have been resetted")
	}
	
	/// In case the user has informed others about the positive result, this function should be called to reset possible pending 'warn others' notifications
	func cancelNotifications() {
		UNUserNotificationCenter.current().cancelWarnOthersNotification()
		Log.info("Warn others: All notifications have been canceled")
	}
	
	// MARK: - Private

	private let store: Store
	
	private func scheduleNotifications() {
		UNUserNotificationCenter.current().scheduleWarnOthersNotifications(
			timeIntervalOne: TimeInterval(notificationOneTimeInterval),
			timeIntervalTwo: TimeInterval(notificationTwoTimeInterval)
		)
		Log.info("Warn Others: New notifications have been scheduled:  #1 \(store.warnOthersNotificationOneTimer)/ #2 \(store.warnOthersNotificationTwoTimer) seconds)")
	}
	
}
