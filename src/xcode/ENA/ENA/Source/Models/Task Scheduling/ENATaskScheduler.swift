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
	case fetchTestResults = "fetch-test-results"

	var backgroundTaskScheduleInterval: TimeInterval? {
		switch self {
		case .exposureNotification: return nil
		case .fetchTestResults: return 2 * 60 * 60
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
		registerTask(with: .exposureNotification, taskHandler: executeExposureDetectionRequest(_:))
		registerTask(with: .fetchTestResults, taskHandler: executeFetchTestResults(_:))
	}

	private func registerTask(with taskIdentifier: ENATaskIdentifier, taskHandler: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			log(message: "#BGTASK: \(task.identifier) EXECUTING", logToFile: true)
			taskHandler(task)
			task.expirationHandler = {
				log(message: "#BGTASK: \(task.identifier) EXPIRED", logToFile: true)
				task.setTaskCompleted(success: false)
			}
		}
	}

	func scheduleTasks() {
		BGTaskScheduler.shared.getPendingTaskRequests { requests in
			let pendingTaskIdentifiers = requests.map({ $0.identifier })
			if !pendingTaskIdentifiers.contains(ENATaskIdentifier.exposureNotification.backgroundTaskSchedulerIdentifier) {
				self.scheduleTask(for: .exposureNotification, cancelExisting: true)
			}
			if !pendingTaskIdentifiers.contains(ENATaskIdentifier.fetchTestResults.backgroundTaskSchedulerIdentifier) {
				self.scheduleTask(for: .fetchTestResults, cancelExisting: true)
			}
		}
	}

	func cancelTasks() {
		log(message: "#BGTASK: CANCELLING ALL TASKS", logToFile: true)
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

		log(message: "#BGTASK: scheduling \(taskRequest.identifier) at \(taskRequest.earliestBeginDate?.description(with: .current) ?? "nil")", logToFile: true)

		do {
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			logError(message: error.localizedDescription)
		}

	}

	func cancelTask(for taskIdentifier: ENATaskIdentifier) {
		log(message: "#BGTASK: \(taskIdentifier) CANCELLING", logToFile: true)
		BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
	}

	func logTasks() {
		log(message: "#BGTASK:", logToFile: true)
		BGTaskScheduler.shared.getPendingTaskRequests { taskRequests in
			taskRequests.forEach { request in
				log(message: "#BGTASK: pendingTasks \(request.identifier) at \(request.earliestBeginDate?.description(with: .current) ?? "nil")", logToFile: true)
			}
		}
	}

	// Task Handlers:
	private func executeExposureDetectionRequest(_ task: BGTask) {
		log(message: "#BGTASK: \(task.identifier) STARTED", logToFile: true)
		taskDelegate?.executeExposureDetectionRequest(task: task) { success in
			log(message: "#BGTASK: \(task.identifier) COMPLETED", logToFile: true)
			log(message: "#BGTASK: logTasks()", logToFile: true)
			self.logTasks()
			task.setTaskCompleted(success: success)
		}
		log(message: "#BGTASK: \(task.identifier) RESCHEDULING", logToFile: true)
		scheduleTask(for: task.identifier)
	}

	private func executeFetchTestResults(_ task: BGTask) {
		log(message: "#BGTASK: \(task.identifier) STARTED", logToFile: true)
		taskDelegate?.executeFetchTestResults(task: task) { success in
			log(message: "#BGTASK: \(task.identifier) COMPLETED", logToFile: true)
			log(message: "#BGTASK: logTasks()", logToFile: true)
			self.logTasks()
			task.setTaskCompleted(success: success)
		}
		log(message: "#BGTASK: \(task.identifier) RESCHEDULING", logToFile: true)
		scheduleTask(for: task.identifier)
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
