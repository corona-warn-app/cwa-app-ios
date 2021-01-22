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
		Log.info("Starting background task…", log: .background)

		let group = DispatchGroup()

		group.enter()
		DispatchQueue.global().async {
			Log.info("Trying to submit TEKs…", log: .background)
			self.executeSubmitTemporaryExposureKeys { _ in
				group.leave()
				Log.info("Done submitting TEKs…", log: .background)
			}
		}

		group.enter()
		DispatchQueue.global().async {
			Log.info("Trying to fetch TestResults…", log: .background)
			self.executeFetchTestResults { _ in
				group.leave()
				Log.info("Done fetching TestResults…", log: .background)
			}
		}

		group.enter()
		DispatchQueue.global().async {
			Log.info("Starting ExposureDetection…", log: .background)
			self.executeExposureDetectionRequest { _ in
				group.leave()
				Log.info("Done detecting Exposures…", log: .background)
			}
		}

		group.enter()
		DispatchQueue.global().async {
			Log.info("Starting FakeRequests…", log: .background)
			self.executeFakeRequests {
				group.leave()
				Log.info("Done sending FakeRequests…", log: .background)
			}
		}

		group.enter()
		DispatchQueue.global().async {
			Log.info("Cleanup contact diary store.", log: .background)
			self.contactDiaryStore.cleanup(timeout: 10.0)
			group.leave()
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	/// This method attempts a submission of temporary exposure keys. The exposure submission service itself checks
	/// whether a submission should actually be executed.
	private func executeSubmitTemporaryExposureKeys(completion: @escaping ((Bool) -> Void)) {
		Log.info("[ENATaskExecutionDelegate] Attempt submission of temporary exposure keys.", log: .api)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		service.submitExposure { error in
			switch error {
			case .noSubmissionConsent:
				Log.info("[ENATaskExecutionDelegate] Submission: no consent given", log: .api)
			case .noKeysCollected:
				Log.info("[ENATaskExecutionDelegate] Submission: no keys to submit", log: .api)
			case .some(let error):
				Log.error("[ENATaskExecutionDelegate] Submission error: \(error.localizedDescription)", log: .api)
			case .none:
				Log.info("[ENATaskExecutionDelegate] Submission successful", log: .api)
			}

			completion(true)
		}
	}

	/// This method executes a  test result fetch, and if it is successful, and the test result is different from the one that was previously
	/// part of the app, a local notification is shown.
	private func executeFetchTestResults(completion: @escaping ((Bool) -> Void)) {
		// First check if user activated notification setting
		guard self.store.allowTestsStatusNotification else {
			completion(false)
			return
		}
		
		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: exposureManager,
			appConfigurationProvider: appConfigurationProvider,
			client: client,
			store: store,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		guard store.registrationToken != nil && store.testResultReceivedTimeStamp == nil else {
			completion(false)
			return
		}
		Log.info("Requesting TestResult…", log: .api)
		service.getTestResult { result in
			switch result {
			case .failure(let error):
				Log.error(error.localizedDescription, log: .api)
			case .success(.pending), .success(.expired):
				// Do not trigger notifications for pending or expired results.
				Log.info("TestResult pending or expired", log: .api)
			case .success(let testResult):
				Log.info("Triggering Notification to inform user about TestResult: \(testResult.stringValue)", log: .api)
				// We attach the test result to determine which screen to show when user taps the notification
				UNUserNotificationCenter.current().presentNotification(
					title: AppStrings.LocalNotifications.testResultsTitle,
					body: AppStrings.LocalNotifications.testResultsBody,
					identifier: ActionableNotificationIdentifier.testResult.identifier,
					info: [ActionableNotificationIdentifier.testResult.identifier: testResult.rawValue]
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
