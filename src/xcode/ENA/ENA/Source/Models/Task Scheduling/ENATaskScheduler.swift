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

protocol ENATaskScheduler: class {
	static var shared: ENATaskScheduler { get }
	var delegate: ENATaskExecutionDelegate? { get set }
	func scheduleTasks()
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeExposureNotificationTask(task: BGTask, completion: @escaping ((Bool) -> Void))
}

/// - NOTE: To simulate the execution of a background task, use the following:
///         e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"de.rki.coronawarnapp-dev.exposure-notification"]
final class SimpleTaskScheduler: ENATaskScheduler {

	// MARK: - Static.

	static var shared: ENATaskScheduler = SimpleTaskScheduler()

	// MARK: - Attributes.

	weak var delegate: ENATaskExecutionDelegate?

	// MARK: - Initializer.

	private init() {
		SimpleTaskScheduler.log(message: "Registering tasks.")
		registerTask(with: .exposureNotification, execute: exposureNotificationTask(_:))
		SimpleTaskScheduler.showNotification(title: "Initialized SimpleTaskScheduler", subtitle: "Success!", body: "You can now put the app in the background.")
	}

	// MARK: - Task registration.
	
	private func registerTask(with taskIdentifier: ENATaskIdentifier, execute: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			task.expirationHandler = {
				task.setTaskCompleted(success: false)
				SimpleTaskScheduler.log(message: "WARNING: expiration handler called for task: \(task).")
			}
			// Make sure to set expiration handler before doing any work.
			execute(task)
		}
	}

	// MARK: - Task scheduling.

	func scheduleTasks() {
		scheduleTask(with: .exposureNotification)
	}

	private func scheduleTask(with taskIdentifier: ENATaskIdentifier) {
		do {
			let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
			taskRequest.requiresNetworkConnectivity = true
			taskRequest.requiresExternalPower = false
			taskRequest.earliestBeginDate = nil
			SimpleTaskScheduler.log(message: "scheduleTask(with: \(taskIdentifier)) built a task request: \(taskRequest)")
			try BGTaskScheduler.shared.submit(taskRequest)
			SimpleTaskScheduler.log(message: "scheduleTask(with: \(taskIdentifier)) submitted a task request: \(taskRequest)")
		} catch {
			SimpleTaskScheduler.log(message: "ERROR! scheduleTask(with: \(taskIdentifier)) could NOT submit task request: \(error)")
		}
	}

	// MARK: - Task execution handlers.

	private func exposureNotificationTask(_ task: BGTask) {
		SimpleTaskScheduler.log(message: "exposureNotificationTask called: \(task). delegate: \(String(describing: delegate))")
		SimpleTaskScheduler.showNotification(title: "ExposureNotificationTask", subtitle: "fired at \(Date())", body: "\(task)")
		delegate?.executeExposureNotificationTask(task: task) { success in
			task.setTaskCompleted(success: success)
			SimpleTaskScheduler.log(message: "exposureNotificationTask delegate callback: set task to completed! \(task)")
			SimpleTaskScheduler.showNotification(title: "ExposureNotificationTask", subtitle: "done at \(Date())", body: "\(task)")
			self.scheduleTask(with: .exposureNotification)
		}
	}

	// MARK: - Util.

	static func log(message: String) {
		let fm = FileManager.default
		guard
			let data = ["\(Date())", message, "\n"].joined(separator: " ").data(using: .utf8),
			let log = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("log.txt")
			else { return }
		if let handle = try? FileHandle(forWritingTo: log) {
			handle.seekToEndOfFile()
			handle.write(data)
			handle.closeFile()
		} else {
			try? data.write(to: log)
		}
		
		print(String(bytes: data, encoding: .utf8) ?? "-")
	}

	private static func showNotification(
		title: String,
		subtitle: String,
		body: String,
		notificationIdentifier: String = "com.sap.ios.cwa.background-test.\(UUID().uuidString)"
	) {
			let content = UNMutableNotificationContent()
			content.title = title
			content.subtitle = subtitle
			content.body = body

			let trigger = UNTimeIntervalNotificationTrigger(
				timeInterval: 1,
				repeats: false
			)

			let request = UNNotificationRequest(
				identifier: notificationIdentifier,
				content: content,
				trigger: trigger
			)

			UNUserNotificationCenter.current().add(request) { error in
				guard let error = error else { return }
				logError(message: "There was an error scheduling the local notification. \(error.localizedDescription)")
			}
	}
}

extension SimpleTaskScheduler: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		// NOTE: Intentionally not implemented.
		// This used to be an optimization that prevented unnecessary
		// background tasks when the exposure detection is disabled.

		/*if state.isGood {
			scheduleTasks()
		} else {
			cancelTasks()
		}*/
	}
}
