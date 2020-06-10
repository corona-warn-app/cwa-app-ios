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
	case fetchTestResults = "fetch-test-results"

	var backgroundTaskScheduleInterval: TimeInterval? {
		switch self {
		// set to trigger every 2 hours
		case .fetchTestResults: return 2 * 60 * 60
		}
	}
	var backgroundTaskSchedulerIdentifier: String {
		"\(Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp").\(rawValue)"
	}
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeExposureDetectionRequest(task: BGTask)
	func executeFetchTestResults(task: BGTask)
}

final class ENATaskScheduler {
	static let shared = ENATaskScheduler()

	var didCompleteExposureDetectionRequest: Bool = false
	var didCompleteFetchTestResults: Bool = false

	func didCompleteTasks() -> Bool {
		if didCompleteFetchTestResults && didCompleteExposureDetectionRequest {
			didCompleteExposureDetectionRequest = false
			didCompleteFetchTestResults = false
			return true
		} else {
			return false
		}
	}

	private init() {
		registerTasks()
	}

	weak var taskDelegate: ENATaskExecutionDelegate?

	typealias CompletionHandler = (() -> Void)

	private func registerTasks() {
		registerTask(with: .fetchTestResults, taskHander: executeFetchTestResults(_:))
	}

	private func registerTask(with taskIdentifier: ENATaskIdentifier, taskHander: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			taskHander(task)
		}
	}

	func scheduleTasks() {
		scheduleTask(for: .fetchTestResults, cancelExisting: true)
	}

	func cancelTasks() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
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
		guard let taskDelegate = taskDelegate else {
			task.setTaskCompleted(success: false)
			scheduleTasks()
			return
		}
		taskDelegate.executeExposureDetectionRequest(task: task)
	}

	private func executeFetchTestResults(_ task: BGTask) {
		guard let taskDelegate = taskDelegate else {
			task.setTaskCompleted(success: false)
			scheduleTasks()
			return
		}
		taskDelegate.executeFetchTestResults(task: task)
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
