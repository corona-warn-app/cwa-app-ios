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
import BackgroundTasks
import UIKit

extension AppDelegate: ENATaskExecutionDelegate {

	/// This method executes the background tasks needed for: a) fetching test results and b) performing exposure detection requests
	func executeENABackgroundTask(task: BGTask, completion: @escaping ((Bool) -> Void)) {
		executeFetchTestResults(task: task) { fetchTestResultSuccess in

			// NOTE: We are currently fetching the test result first, and then execute
			// the exposure detection check. Instead of implementing this behaviour in the completion handler,
			// queues could be used as well. Due to time/resource constraints, we settled for this option.
			self.executeExposureDetectionRequest(task: task) { exposureDetectionSuccess in
				self.executeFakeRequests() {
					completion(fetchTestResultSuccess && exposureDetectionSuccess)
				}
			}
		}
	}

	/// This method executes a  test result fetch, and if it is successful, and the test result is different from the one that was previously
	/// part of the app, a local notification is shown.
	/// NOTE: This method will always return true.
	private func executeFetchTestResults(task: BGTask, completion: @escaping ((Bool) -> Void)) {

		let service = exposureSubmissionService ?? ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		if store.registrationToken != nil && store.testResultReceivedTimeStamp == nil {
			service.getTestResult { result in
				switch result {
				case .failure(let error):
					logError(message: error.localizedDescription)
				case .success(let testResult):
					if testResult != .pending {
						UNUserNotificationCenter.current().presentNotification(
							title: AppStrings.LocalNotifications.testResultsTitle,
							body: AppStrings.LocalNotifications.testResultsBody,
							identifier: task.identifier
						)
					}
				}

				completion(true)
			}
		} else {
			completion(true)
		}

	}

	/// This method performs a check for the current exposure detection state. Only if the risk level has changed compared to the
	/// previous state, a local notification is shown.
	/// NOTE: This method will always return true.
	private func executeExposureDetectionRequest(task: BGTask, completion: @escaping ((Bool) -> Void)) {

		let detectionMode = DetectionMode.fromBackgroundStatus()
		riskProvider.configuration.detectionMode = detectionMode

		riskProvider.requestRisk(userInitiated: false) { risk in
			// present a notification if the risk score has increased.
			if let risk = risk,
				risk.riskLevelHasChanged {
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.detectExposureTitle,
					body: AppStrings.LocalNotifications.detectExposureBody,
					identifier: task.identifier
				)
			}
			completion(true)
		}
	}

}
