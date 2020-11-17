//
// 🦠 Corona-Warn-App
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

		let service = ENAExposureSubmissionService(diagnosiskeyRetrieval: exposureManager, client: client, store: store)

		guard store.registrationToken != nil && store.testResultReceivedTimeStamp == nil else {
			completion(false)
			return
		}

		service.getTestResult { result in
			switch result {
			case .failure(let error):
				Log.error(error.localizedDescription, log: .api)
			case .success(.pending), .success(.expired):
				// Do not trigger notifications for pending or expired results.
				break
			case .success:
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.testResultsTitle,
					body: AppStrings.LocalNotifications.testResultsBody,
					identifier: ActionableNotificationIdentifier.testResult.identifier
				)
			}

			completion(true)
		}
	}

	/// This method performs a check for the current exposure detection state. Only if the risk level has changed compared to the
	/// previous state, a local notification is shown.
	private func executeExposureDetectionRequest(completion: @escaping ((Bool) -> Void)) {
		Log.info("[ENATaskExecutionDelegate] Execute exposure detection.", log: .riskDetection)

		// At this point we are already in background so it is safe to assume background mode is available.
		riskProvider.riskProvidingConfiguration.detectionMode = .fromBackgroundStatus(.available)

		backgroundTaskConsumer = RiskConsumer()
		riskProvider.observeRisk(backgroundTaskConsumer)

		backgroundTaskConsumer.didCalculateRisk = { [weak self] risk in
			Log.info("[ENATaskExecutionDelegate] Execute exposure detection did calculate risk.", log: .riskDetection)

			guard let self = self else { return }
			if risk.riskLevelHasChanged {
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.detectExposureTitle,
					body: AppStrings.LocalNotifications.detectExposureBody,
					identifier: ActionableNotificationIdentifier.riskDetection.identifier
				)
				Log.info("[ENATaskExecutionDelegate] Risk has changed.", log: .riskDetection)
				completion(true)
			} else {
				Log.info("[ENATaskExecutionDelegate] Risk has not changed.", log: .riskDetection)
				completion(false)
			}

			self.riskProvider.removeRisk(self.backgroundTaskConsumer)
		}

		backgroundTaskConsumer.didFailCalculateRisk = { [weak self] error in
			guard let self = self else { return }

			// Ignore already running errors.
			// In other words: if the RiskProvider is already running, we wait for other callbacks.
			guard !error.isAlreadyRunningError else {
				Log.info("[ENATaskExecutionDelegate] Ignore already running error.", log: .riskDetection)
				return
			}

			Log.error("[ENATaskExecutionDelegate] Exposure detection failed.", log: .riskDetection, error: error)

			switch error {
			case .failedRiskDetection(let reason):
				if case .wrongDeviceTime = reason {
					if !self.store.wasDeviceTimeErrorShown {
						UNUserNotificationCenter.current().presentNotification(
							title: AppStrings.WrongDeviceTime.errorPushNotificationTitle,
							body: AppStrings.WrongDeviceTime.errorPushNotificationText,
							identifier: ActionableNotificationIdentifier.deviceTimeCheck.identifier
						)
						self.store.wasDeviceTimeErrorShown = true
					}
				}
			default:
				break
			}

			completion(false)
			self.riskProvider.removeRisk(self.backgroundTaskConsumer)
		}

		riskProvider.requestRisk(userInitiated: false)
	}
}
