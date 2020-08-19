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

import BackgroundTasks
import ExposureNotification
import UIKit

enum ENATaskIdentifier: String, CaseIterable {
	// only one task identifier is allowed have the .exposure-notification suffix
	case exposureNotification = "exposure-notification"

	var backgroundTaskSchedulerIdentifier: String {
		guard let bundleID = Bundle.main.bundleIdentifier else { return "invalid-task-id!" }
		return "\(bundleID).\(rawValue)"
	}
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeENABackgroundTask(completion: @escaping ((Bool) -> Void))
}

/// - NOTE: To simulate the execution of a background task, use the following:
///         e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"de.rki.coronawarnapp-dev.exposure-notification"]
///         To simulate the expiration of a background task, use the following:
///         e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"de.rki.coronawarnapp-dev.exposure-notification"]
final class ENATaskScheduler {

	// MARK: - Static.

	static let shared = ENATaskScheduler()

	// MARK: - Attributes.

	weak var delegate: ENATaskExecutionDelegate?

	// MARK: - Initializer.

	private init() {
		registerTask(with: .exposureNotification, execute: exposureNotificationTask(_:))
	}

	// MARK: - Task registration.

	private func registerTask(with taskIdentifier: ENATaskIdentifier, execute: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			self.scheduleTask()
			let backgroundTask = DispatchWorkItem {
				execute(task)
			}

			task.expirationHandler = {
				self.scheduleTask()
				backgroundTask.cancel()
				logError(message: "Task has expired.")
				task.setTaskCompleted(success: false)
			}

			DispatchQueue.global().async(execute: backgroundTask)
		}
	}

	// MARK: - Task scheduling.

	func scheduleTask() {
		do {
			ENATaskScheduler.scheduleDeadmanNotification()
			let taskRequest = BGProcessingTaskRequest(identifier: ENATaskIdentifier.exposureNotification.backgroundTaskSchedulerIdentifier)
			taskRequest.requiresNetworkConnectivity = true
			taskRequest.requiresExternalPower = false
			taskRequest.earliestBeginDate = nil
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			logError(message: "ERROR: scheduleTask() could NOT submit task request: \(error)")
		}
	}

	// MARK: - Task execution handlers.

	private func exposureNotificationTask(_ task: BGTask) {
		delegate?.executeENABackgroundTask { success in
			task.setTaskCompleted(success: success)
		}
	}

	// MARK: - Deadman notifications.

	/// Schedules a local notification to fire 36 hours from now.
	/// In case the background execution fails  there will be a backup notification for the
	/// user to be notified to open the app. If everything runs smoothly,
	/// the current notification will always be moved to the future, thus never firing.
	static func scheduleDeadmanNotification() {
		let notificationCenter = UNUserNotificationCenter.current()

		let content = UNMutableNotificationContent()
		content.title = AppStrings.Common.deadmanAlertTitle
		content.body = AppStrings.Common.deadmanAlertBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(
			timeInterval: 36 * 60 * 60,
			repeats: false
		)

		// bundleIdentifier is defined in Info.plist and can never be nil!
		guard let bundleID = Bundle.main.bundleIdentifier else {
			logError(message: "Could not access bundle identifier")
			return
		}

		let request = UNNotificationRequest(
			identifier: bundleID + ".notifications.cwa-deadman",
			content: content,
			trigger: trigger
		)

		notificationCenter.add(request) { error in
		   if error != nil {
			  logError(message: "Deadman notification could not be scheduled.")
		   }
		}
	}

}
