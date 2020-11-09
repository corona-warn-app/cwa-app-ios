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

/// The `WarnOthers` clsas  behaves as a facade and encaplsulate all relevant logic whether to schedule or not to schedule warn others notifications about a positiv test result.
/// Notification scheduling - the app will inform the user 2 times to warn others.
/// WarnOthers always is related to one concrete test result, which always needs to be a positive one.
class WarnOthers: OthersWarnable {
	
	var storedResult: Bool {
		get {
			return store.warnOthersHasActiveTestResult
		}
		set {
			store.warnOthersHasActiveTestResult = newValue
		}
	}
	
	/// Notification timer in seconds for notification one
	var notificationOneTimer: TimeInterval {
		get {
			return TimeInterval(store.warnOthersNotificationOneTimer)
		}
		set {
			store.warnOthersNotificationOneTimer = Int(newValue)
		}
	}
	
	/// Notification timer in seconds for notification two
	var notificationTwoTimer: TimeInterval {
		get {
			return TimeInterval(store.warnOthersNotificationTwoTimer)
		}
		set {
			store.warnOthersNotificationTwoTimer = Int(newValue)
		}
	}
	
	private let store: Store
	
	// MARK: - Init
	init(store: Store) {
		self.store = store
		self.storedResult = store.warnOthersHasActiveTestResult
	}
	
	// MARK: - public
	/// This function takes a `TestResult` as parameter to evaluate, if possible notifications need to be scheduled for the warn others notification process.
	func evaluateNotificationState(testResult: TestResult) {
		
		// If incoming test restuls are others than positive, we don't deal with them
		guard testResult == .positive, storedResult == false else { return }
		
		// We are "clean" to go. So lock the door until result was removed
		storedResult = true
		
		scheduleNotifications()
	}
	
	func reset() {
		cancelNotifications()
		storedResult = false
		Log.info("Warn others have been resetted")
	}
	
	/// In case the user has informed others about the positive result, this function should be called to reset possible pending 'warn others' notifications
	func cancelNotifications() {
		UNUserNotificationCenter.current().cancelWarnOthersNotification()
		Log.info("Warn others: All notifications have been canceled")
	}
	
	// MARK: - private API
	private func scheduleNotifications() {
		UNUserNotificationCenter.current().scheduleWarnOthersNotifications(
			timeIntervalOne: TimeInterval(notificationOneTimer),
			timeIntervalTwo: TimeInterval(notificationTwoTimer)
		)
		
		Log.info("Warn Others: New notifications have been scheduled:  #1 \(store.warnOthersNotificationOneTimer)/ #2 \(store.warnOthersNotificationTwoTimer) seconds)")
	}
	
}
