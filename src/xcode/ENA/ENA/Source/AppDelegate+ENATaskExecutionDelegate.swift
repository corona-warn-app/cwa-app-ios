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

	/// This method executes the background tasks needed for fetching test results, performing exposure detection
	/// and executing plausible deniability fake requests.
	///
	/// - NOTE: The method explicitly ignores the outcomes of all subtasks (success/failure) and will _always_
	///         call completion(true) when the subtasks finished regardless of their individual results.
	///         This will set the background task state to _completed_. We only mark the task as incomplete
	///         when the OS calls the expiration handler before all tasks were able to finish.
	func executeENABackgroundTask(completion: @escaping ((Bool) -> Void)) {
		let group = DispatchGroup()

		group.enter()
		DispatchQueue.global().async {
			self.executeFetchTestResults { _ in group.leave() }
		}

		group.enter()
		DispatchQueue.global().async {
			self.executeExposureDetectionRequest { _ in group.leave() }
		}

		group.enter()
		DispatchQueue.global().async {
			self.executeFakeRequests { group.leave() }
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	/// This method executes a  test result fetch, and if it is successful, and the test result is different from the one that was previously
	/// part of the app, a local notification is shown.
	private func executeFetchTestResults(completion: @escaping ((Bool) -> Void)) {

		let service = exposureSubmissionService ?? ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		guard store.registrationToken != nil && store.testResultReceivedTimeStamp == nil else {
			completion(false)
			return
		}

		service.getTestResult { result in
			switch result {
			case .failure(let error):
				logError(message: error.localizedDescription)
			case .success(.pending), .success(.redeemed):
				// Do not trigger notifications for pending or redeemed results.
				break
			case .success:
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.testResultsTitle,
					body: AppStrings.LocalNotifications.testResultsBody,
					identifier: ENATaskIdentifier.exposureNotification.backgroundTaskSchedulerIdentifier + ".test-result"
				)
			}

			completion(true)
		}
	}

	/// This method performs a check for the current exposure detection state. Only if the risk level has changed compared to the
	/// previous state, a local notification is shown.
	private func executeExposureDetectionRequest(completion: @escaping ((Bool) -> Void)) {

		// At this point we are already in background so it is safe to assume background mode is available.
		riskProvider.configuration.detectionMode = .fromBackgroundStatus(.available)

		riskProvider.requestRisk(userInitiated: false) { risk in
			guard let risk = risk, risk.riskLevelHasChanged else {
				completion(false)
				return
			}

			UNUserNotificationCenter.current().presentNotification(
				title: AppStrings.LocalNotifications.detectExposureTitle,
				body: AppStrings.LocalNotifications.detectExposureBody,
				identifier: ENATaskIdentifier.exposureNotification.backgroundTaskSchedulerIdentifier + ".risk-detection"
			)

			completion(true)
		}
	}
}
