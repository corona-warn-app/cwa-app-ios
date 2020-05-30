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
	case exposureNotification = "exposure-notification"
	case fetchTestResults = "fetch-test-results"

	var backgroundTaskScheduleInterval: TimeInterval {
		switch self {
		case .exposureNotification: return 15 * 60 // 2 * 60 * 60 // set to trigger every 2 hours
		case .fetchTestResults: return 5 * 60 // 30 * 60     // set to trigger every 30 min
		}
	}

	var backgroundTaskSchedulerIdentifier: String {
		"\(Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp").\(rawValue)"
	}
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeExposureDetectionRequest(task: BGTask, completionHandler: (Bool) -> Void)
	func executeFetchTestResults(task: BGTask, completionHandler: (Bool) -> Void)
}

public class ENATaskScheduler {
	weak var taskDelegate: ENATaskExecutionDelegate?
	lazy var manager = ENAExposureManager()
	lazy var notificationManager = LocalNotificationManager()
	typealias CompletionHandler = (() -> Void)

	public func registerBackgroundTaskRequests() {
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) STARTED")
		cancelAllBackgroundTaskRequests()
		registerTask(with: .exposureNotification, taskHander: executeExposureDetectionRequest(_:))
		registerTask(with: .fetchTestResults, taskHander: executeFetchTestResults(_:))
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) COMPLETED")
	}

	public func scheduleBackgroundTaskRequests() {
		appLogger.info(message: "# TASKSHED # \(#line), \(#function)")
		BGTaskScheduler.shared.cancelAllTaskRequests()
		scheduleBackgroundTask(for: .exposureNotification)
		scheduleBackgroundTask(for: .fetchTestResults)
	}

	public func isBackgroundRefreshEnabled() -> Bool {
		UIApplication.shared.backgroundRefreshStatus == .available
	}

	public func arePendingTasksScheduled(completionHandler: @escaping ((Bool) -> Void)) {
		fetchPendingBackgroundTaskRequests { requests in
			completionHandler(!requests.isEmpty)
		}
	}

	public func fetchPendingBackgroundTaskRequests(completionHandler: @escaping (([BGTaskRequest]) -> Void)) {
		BGTaskScheduler.shared.getPendingTaskRequests { requests in
			completionHandler(requests)
		}
	}

	public func cancelAllBackgroundTaskRequests() {
		appLogger.info(message: "# TASKSHED # \(#line), \(#function)")
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	private func registerTask(with identifier: ENATaskIdentifier, taskHander: @escaping ((BGTask) -> Void)) {
		let identifierString = identifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: nil) { task in
			taskHander(task)
		}
	}

	public func scheduleBackgroundTask(for taskIdentifier: ENATaskIdentifier) {
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) SCHEDULING \(taskIdentifier.backgroundTaskSchedulerIdentifier)")

		if taskIdentifier == .exposureNotification, manager.preconditions().isGood == false || UIApplication.shared.backgroundRefreshStatus != .available {
			appLogger.info(message: "# TASKSHED # \(#line), \(#function) UNABLE TO SCHEDULE \(taskIdentifier.backgroundTaskSchedulerIdentifier)")
			return
		}

		let earliestBeginDate = Date(timeIntervalSinceNow: taskIdentifier.backgroundTaskScheduleInterval)
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) TIME NOW IS  :\(Date(timeIntervalSinceNow: 0))")
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) SCHEDULED at :\(earliestBeginDate)")

		let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
		taskRequest.requiresNetworkConnectivity = true
		taskRequest.requiresExternalPower = false
		taskRequest.earliestBeginDate = earliestBeginDate
		do {
			try BGTaskScheduler.shared.submit(taskRequest)
		} catch {
			appLogger.info(message: "# TASHSHED # Unable to schedule background task \(taskIdentifier.backgroundTaskSchedulerIdentifier): \(error)")
		}
	}

	// Task Handlers:
	private func executeExposureDetectionRequest(_ task: BGTask) {
		let scheduler: ENATaskScheduler? = self
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) taskScheduler = \(String(describing: scheduler))")
		guard let taskDelegate = taskDelegate else {
			appLogger.info(message: "# TASKSHED # \(#line), \(#function) taskDelegate = nil")
			return
		}
		taskDelegate.executeExposureDetectionRequest(task: task) { success in
			task.setTaskCompleted(success: success)
		}
	}

	private func executeFetchTestResults(_ task: BGTask) {
		let scheduler: ENATaskScheduler? = self
		appLogger.info(message: "# TASKSHED # \(#line), \(#function) taskScheduler = \(String(describing: scheduler))")
		guard let taskDelegate = taskDelegate else {
			appLogger.info(message: "# TASKSHED # \(#line), \(#function) taskDelegate = nil")
			return
		}
		taskDelegate.executeFetchTestResults(task: task) { success in
			task.setTaskCompleted(success: success)
		}
	}
}
