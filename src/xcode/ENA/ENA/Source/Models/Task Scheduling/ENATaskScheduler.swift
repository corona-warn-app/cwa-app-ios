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
	case SIMPLETEST = "SIMPLETEST"

	var backgroundTaskScheduleInterval: TimeInterval {
		switch self {
		// set to trigger every 2 hours
		case .detectExposures: return 2 * 60 * 60
		// set to trigger every 30 min
		case .fetchTestResults: return 2 * 60 * 60
		// set to trigger every 15 min
		case .SIMPLETEST: return 15 * 60
		}
	}

	var backgroundTaskSchedulerIdentifier: String {
		"\(Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp").\(rawValue)"
	}
}

protocol ENATaskExecutionDelegate: AnyObject {
	func executeExposureDetectionRequest(task: BGTask)
	func executeFetchTestResults(task: BGTask)
	func executeSIMPLETEST(task: BGTask)
}

public class ENATaskScheduler {
	weak var taskDelegate: ENATaskExecutionDelegate?
	lazy var manager = ENAExposureManager()
	lazy var notificationManager = LocalNotificationManager()
	typealias CompletionHandler = (() -> Void)

	public func registerBackgroundTaskRequests() {
		log(message: "# TASKSHED # \(#line), \(#function) STARTED")
		registerTask(with: .detectExposures, taskHander: executeExposureDetectionRequest(_:))
		registerTask(with: .fetchTestResults, taskHander: executeFetchTestResults(_:))
		registerTask(with: .SIMPLETEST, taskHander: executeSIMPLETEST(_:))
		log(message: "# TASKSHED # \(#line), \(#function) COMPLETED")
	}

	public func scheduleBackgroundTaskRequests() {
		log(message: "# TASKSHED # \(#line), \(#function)")
		BGTaskScheduler.shared.cancelAllTaskRequests()
		scheduleBackgroundTask(for: .detectExposures)
		scheduleBackgroundTask(for: .fetchTestResults)
		scheduleBackgroundTask(for: .SIMPLETEST)
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

	public func listPendingTasks() {
		self.fetchPendingBackgroundTaskRequests { requests in
			requests.forEach { request in
				log(message: "# TASKSHED # \(#line) \(#function) PENDING REQUEST \(request.identifier) at \(request.earliestBeginDate?.description(with: .current) ?? "<unknown>")")
			}
		}
	}

	public func cancelAllBackgroundTaskRequests() {
		log(message: "# TASKSHED # \(#line), \(#function)")
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	private func registerTask(with taskIdentifier: ENATaskIdentifier, taskHander: @escaping ((BGTask) -> Void)) {
		log(message: "# TASKSHED # \(#line), \(#function) REGISTERING \(taskIdentifier.backgroundTaskSchedulerIdentifier)")
		let identifierString = taskIdentifier.backgroundTaskSchedulerIdentifier
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifierString, using: nil) { task in
			taskHander(task)
		}
	}

	public func scheduleBackgroundTask(for taskIdentifier: ENATaskIdentifier) {
		log(message: "# TASKSHED # \(#line), \(#function) SCHEDULING \(taskIdentifier.backgroundTaskSchedulerIdentifier)")

		if taskIdentifier == .detectExposures, manager.preconditions().isGood == false || UIApplication.shared.backgroundRefreshStatus != .available {
			log(message: "# TASKSHED # \(#line), \(#function) UNABLE TO SCHEDULE \(taskIdentifier.backgroundTaskSchedulerIdentifier)")
			return
		}

		let earliestBeginDate = Date(timeIntervalSinceNow: taskIdentifier.backgroundTaskScheduleInterval)
		let taskRequest = BGProcessingTaskRequest(identifier: taskIdentifier.backgroundTaskSchedulerIdentifier)
		taskRequest.requiresNetworkConnectivity = true
		taskRequest.requiresExternalPower = false
		taskRequest.earliestBeginDate = earliestBeginDate
		do {
			try BGTaskScheduler.shared.submit(taskRequest)
			log(message: "# TASKSHED # \(#line), \(#function) SCHEDULED \(taskIdentifier.backgroundTaskSchedulerIdentifier) at \(earliestBeginDate.description(with: .current))")
		} catch {
			log(message: "# TASKSHED # FAILED TO SCHEDULE \(taskIdentifier.backgroundTaskSchedulerIdentifier): \(error)")
		}
	}

	// Task Handlers:
	private func executeExposureDetectionRequest(_ task: BGTask) {
		let scheduler: ENATaskScheduler? = self
		log(message: "# TASKSHED # \(#line), \(#function) taskScheduler = \(String(describing: scheduler))")
		guard let taskDelegate = taskDelegate else {
			log(message: "# TASKSHED # \(#line), \(#function) taskDelegate = nil")
			return
		}
		taskDelegate.executeExposureDetectionRequest(task: task)
	}

	private func executeFetchTestResults(_ task: BGTask) {
		let scheduler: ENATaskScheduler? = self
		log(message: "# TASKSHED # \(#line), \(#function) taskScheduler = \(String(describing: scheduler))")
		guard let taskDelegate = taskDelegate else {
			log(message: "# TASKSHED # \(#line), \(#function) taskDelegate = nil")
			return
		}
		taskDelegate.executeFetchTestResults(task: task)
	}

	private func executeSIMPLETEST(_ task: BGTask) {
		let scheduler: ENATaskScheduler? = self
		log(message: "# TASKSHED # \(#line), \(#function) taskScheduler = \(String(describing: scheduler))")
		guard let taskDelegate = taskDelegate else {
			log(message: "# TASKSHED # \(#line), \(#function) taskDelegate = nil")
			return
		}
		taskDelegate.executeSIMPLETEST(task: task)
	}
}
