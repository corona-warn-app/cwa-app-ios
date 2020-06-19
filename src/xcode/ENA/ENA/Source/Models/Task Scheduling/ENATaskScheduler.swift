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
	case primaryBackgroundTask = "exposure-notification"
	case secondardBackgroundTask = "fetch-test-results"

	var backgroundTaskScheduleInterval: TimeInterval? {
		switch self {
		case .primaryBackgroundTask: return nil
		case .secondardBackgroundTask: return nil
		}
	}
	var backgroundTaskSchedulerIdentifier: String {
		guard let bundleID = Bundle.main.bundleIdentifier else { return "invalid-task-id!" }
		return "\(bundleID).\(rawValue)"
	}
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeExposureDetectionRequest(task: BGTask, completion: @escaping ((Bool) -> Void))
	func executeFetchTestResults(task: BGTask, completion: @escaping ((Bool) -> Void))
}

final class ENATaskScheduler {
	static let shared = ENATaskScheduler()

	private init() {
		registerTasks()
	}

	weak var taskDelegate: ENATaskExecutionDelegate?

	typealias CompletionHandler = (() -> Void)

	private func registerTasks() {
		registerTask(with: .primaryBackgroundTask, taskHander: executeExposureDetectionRequest(_:))
		registerTask(with: .secondardBackgroundTask, taskHander: executeFetchTestResults(_:))
	}

	private func registerTask(with taskIdentifier: ENATaskIdentifier, taskHander: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			taskHander(task)
		}
	}

	func scheduleTasks() {
		scheduleTask(for: .primaryBackgroundTask, cancelExisting: true)
	}

	func cancelTasks() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	func scheduleTask(for identifier: String) {
		guard let taskIdentifier = ENATaskIdentifier(rawValue: identifier) else { return }
		scheduleTask(for: taskIdentifier)
	}

	func scheduleTask(for taskIdentifier: ENATaskIdentifier, cancelExisting: Bool = false) {

		if cancelExisting {
			cancelTask(for: taskIdentifier)
		}

		let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
		taskRequest.requiresNetworkConnectivity = true
		taskRequest.requiresExternalPower = false
		if let interval = taskIdentifier.backgroundTaskScheduleInterval {
			taskRequest.earliestBeginDate = Date(timeIntervalSinceNow: interval)
		} else {
			taskRequest.earliestBeginDate = nil
		}

		do {
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			logError(message: error.localizedDescription)
		}

	}

	func cancelTask(for taskIdentifier: ENATaskIdentifier) {
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
	}

	// Task Handlers:
	private func executeExposureDetectionRequest(_ task: BGTask) {
		taskDelegate?.executeExposureDetectionRequest(task: task) { success in
			task.setTaskCompleted(success: success)
			self.scheduleTask(for: task.identifier)
		}
	}

	private func executeFetchTestResults(_ task: BGTask) {
		taskDelegate?.executeFetchTestResults(task: task) { success in
			task.setTaskCompleted(success: success)
		}
	}

}

extension ENATaskScheduler: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		if state.isGood {
			scheduleTasks()
		} else {
			cancelTasks()
		}
	}
}
