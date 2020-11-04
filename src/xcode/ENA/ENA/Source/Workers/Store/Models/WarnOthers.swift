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

import Foundation

/// The `WarnOthers` clsas  behaves as a facade and encaplsulate all relevant logic whether to schedule or not to schedule warn others notifications about a positiv test result.
/// Notification scheduling - the app will inform the user 2 times to warn others.
/// WarnOthers always is related to one concrete test result, which always needs to be a positive one.
class WarnOthers {
	
//	/// timerOne represents a timer value in seconds
//	var timerOne: Int = ENWarnOthersNotifications.notificationOneDefaultDelay.rawValue
//
//	/// timerTwo represents a timer value in seconds
//	var timerTwo: Int = ENWarnOthersNotifications.notificationTwoDefaultDelay.rawValue
	
	var storedResult = false
	
	private let store: Store
	
	init(store: Store) {
		self.store = store
	}
	
	/// This function takes a `TestResult` as parameter to evaluate, if possible notifications need to be scheduled for the warn others notification process.
	func evaluateNotificationState(testResult: TestResult) {
		
		// If incoming test restuls are others than positive, we don't deal with them
		guard testResult == .positive, storedResult == false else { return }
		
		// We are "clean" to go. So lock the door until result was removed
		storedResult = true
		
		scheduleNotifications()
	}
	
	/// In case the user has informed others about the positive result, this function should be called to reset possible pending 'warn others' notifications
	func cancelNotifications() {
		// TODO: Implement cancel logic
	}
	
	/// Returns the schedule timer time in seconds for timer one
	func getNotificationTimerOne() -> Int {
		return store.warnOthersNotificationOneDelay
	}
	
	/// Sets a new timer value for timer one in seconds
	func setNotificationTimerOne(seconds: Int) {
		store.warnOthersNotificationOneDelay = seconds
	}
	
	/// Returns the schedule timer time in seconds for timer two
	func getNotificationTimerTwo() -> Int {
		return store.warnOthersNotificationTwoDelay
	}
	
	/// Sets a new timer value for timer two in seconds
	func setNotificationsTimerTwo(seconds: Int) {
		store.warnOthersNotificationTwoDelay = seconds
	}
	
	func reset() {
		cancelNotifications()
		storedResult = false
	}
	
	// MARK: - private API
	private func scheduleNotifications() {
		
		// TODO: (mpu) - implement logic
	}
	
}
