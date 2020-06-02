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

public enum ENATaskIdentifier: String, CaseIterable {
	// only one task identifier is allowed have the .exposure-notification suffix
	case detectExposures = "detect-exposures.exposure-notification"
	case fetchTestResults = "fetch-test-results"

	var backgroundTaskScheduleInterval: TimeInterval {
		switch self {
		// set to trigger every 2 hours
		case .detectExposures: return 2 * 60 * 60
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

public class ENATaskScheduler {
	weak var taskDelegate: ENATaskExecutionDelegate?
	lazy var notificationManager = LocalNotificationManager()
	typealias CompletionHandler = (() -> Void)

	public func registerBackgroundTaskRequests() {
		registerTask(with: .detectExposures, taskHander: executeExposureDetectionRequest(_:))
		registerTask(with: .fetchTestResults, taskHander: executeFetchTestResults(_:))
	}

	public func scheduleBackgroundTaskRequests() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
		scheduleBackgroundTask(for: .detectExposures)
		scheduleBackgroundTask(for: .fetchTestResults)
	}

	public func cancelAllBackgroundTaskRequests() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	private func registerTask(with taskIdentifier: ENATaskIdentifier, taskHander: @escaping ((BGTask) -> Void)) {
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: .main) { task in
			taskHander(task)
		}
	}

	public func scheduleBackgroundTask(for taskIdentifier: ENATaskIdentifier) {

		let earliestBeginDate = Date(timeIntervalSinceNow: taskIdentifier.backgroundTaskScheduleInterval)
		let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
		taskRequest.requiresNetworkConnectivity = true
		taskRequest.requiresExternalPower = false
		taskRequest.earliestBeginDate = earliestBeginDate

		do {
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			logError(message: error.localizedDescription)
		}
	}

	// Task Handlers:
	private func executeExposureDetectionRequest(_ task: BGTask) {
		guard let taskDelegate = taskDelegate else {
			task.setTaskCompleted(success: false)
			scheduleBackgroundTask(for: .detectExposures)
			return
		}
		taskDelegate.executeExposureDetectionRequest(task: task)
	}

	private func executeFetchTestResults(_ task: BGTask) {
		guard let taskDelegate = taskDelegate else {
			task.setTaskCompleted(success: false)
			scheduleBackgroundTask(for: .fetchTestResults)
			return
		}
		taskDelegate.executeFetchTestResults(task: task)
	}

}
