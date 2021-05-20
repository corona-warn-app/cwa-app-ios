//
// 🦠 Corona-Warn-App
//

import BackgroundTasks
import Foundation
import UIKit

class TaskExecutionHandler: ENATaskExecutionDelegate {

	// MARK: - Init

	init(
		riskProvider: RiskProvider,
		plausibleDeniabilityService: PlausibleDeniabilityService,
		contactDiaryStore: DiaryStoring,
		eventStore: EventStoring,
		eventCheckoutService: EventCheckoutService,
		store: Store,
		exposureSubmissionDependencies: ExposureSubmissionServiceDependencies
	) {
		self.riskProvider = riskProvider
		self.pdService = plausibleDeniabilityService
		self.contactDiaryStore = contactDiaryStore
		self.eventStore = eventStore
		self.eventCheckoutService = eventCheckoutService
		self.store = store
		self.dependencies = exposureSubmissionDependencies
	}


	// MARK: - Protocol ENATaskExecutionDelegate

	var pdService: PlausibleDeniability
	var dependencies: ExposureSubmissionServiceDependencies
	var contactDiaryStore: DiaryStoring

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
			Log.info("Starting ExposureDetection…", log: .background)
			self.executeExposureDetectionRequest { _ in
				Log.info("Done detecting Exposures…", log: .background)
				
				/// ExposureDetection should be our highest Priority if we run all other tasks simultaneously we might get killed by the Watchdog while the Detection is running.
				/// This could leave us in a dirty state which causes the ExposureDetection to run too often. This will then lead to Error 13. (https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-5836)
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
					Log.info("Starting FakeRequests…", log: .background)
					self.pdService.executeFakeRequests {
						group.leave()
						Log.info("Done sending FakeRequests…", log: .background)
					}
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Cleanup contact diary store.", log: .background)
					self.contactDiaryStore.cleanup(timeout: 10.0)
					Log.info("Done cleaning up contact diary store.", log: .background)
					group.leave()
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Cleanup event store.", log: .background)
					self.eventStore.cleanup(timeout: 10.0)
					Log.info("Done cleaning up contact event store.", log: .background)
					group.leave()
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Checkout overdue checkins.", log: .background)
					self.eventCheckoutService.checkoutOverdueCheckins()
					Log.info("Done checkin out overdue checkins.", log: .background)
					group.leave()
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Trigger analytics submission.", log: .background)
					self.executeAnalyticsSubmission {
						group.leave()
						Log.info("Done triggering analytics submission…", log: .background)
					}
				}
				
				group.leave() // Leave from the Exposure detection

			}
		}
		
		group.notify(queue: .main) {
			completion(true)
		}
	}

	// MARK: - Internal

	var riskProvider: RiskProvider
	var store: Store

	// MARK: - Private

	private let backgroundTaskConsumer = RiskConsumer()
	private let eventStore: EventStoring
	private let eventCheckoutService: EventCheckoutService

	/// This method attempts a submission of temporary exposure keys. The exposure submission service itself checks
	/// whether a submission should actually be executed.
	private func executeSubmitTemporaryExposureKeys(completion: @escaping ((Bool) -> Void)) {
		Log.info("[ENATaskExecutionDelegate] Attempt submission of temporary exposure keys.", log: .api)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: dependencies.exposureManager,
			appConfigurationProvider: dependencies.appConfigurationProvider,
			client: dependencies.client,
			store: dependencies.store,
			eventStore: dependencies.eventStore,
			coronaTestService: dependencies.coronaTestService
		)

		let group = DispatchGroup()

		for coronaTestType in CoronaTestType.allCases {
			group.enter()
			service.submitExposure(coronaTestType: coronaTestType) { error in
				switch error {
				case .noCoronaTestOfGivenType:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false)))
					Log.info("[ENATaskExecutionDelegate] Submission: no corona test of type \(coronaTestType) registered", log: .api)
				case .noSubmissionConsent:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false)))
					Log.info("[ENATaskExecutionDelegate] Submission: no consent given", log: .api)
				case .noKeysCollected:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false)))
					Log.info("[ENATaskExecutionDelegate] Submission: no keys to submit", log: .api)
				case .some(let error):
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false)))
					Log.error("[ENATaskExecutionDelegate] Submission error: \(error.localizedDescription)", log: .api)
				case .none:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true)))
					Log.info("[ENATaskExecutionDelegate] Submission successful", log: .api)
				}

				group.leave()
			}
		}

		group.notify(queue: .main) {
			completion(true)
		}
	}

	/// This method executes a  test result fetch, and if it is successful, and the test result is different from the one that was previously
	/// part of the app, a local notification is shown.
	private func executeFetchTestResults(completion: @escaping ((Bool) -> Void)) {
		// First check if user activated notification setting
		guard self.dependencies.store.allowTestsStatusNotification else {
			completion(false)
			return
		}

		dependencies.coronaTestService.updateTestResults(force: false, presentNotification: true) { result in
			switch result {
			case .success:
				completion(true)
			case .failure:
				completion(false)
			}
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
					if !self.dependencies.store.wasDeviceTimeErrorShown {
						UNUserNotificationCenter.current().presentNotification(
							title: AppStrings.WrongDeviceTime.errorPushNotificationTitle,
							body: AppStrings.WrongDeviceTime.errorPushNotificationText,
							identifier: ActionableNotificationIdentifier.deviceTimeCheck.identifier
						)
						self.dependencies.store.wasDeviceTimeErrorShown = true
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

	private func executeAnalyticsSubmission(completion: @escaping () -> Void) {
		// update the risk exposure metadatas if new risk calculations are not done in the meanwhile
		Analytics.collect(.riskExposureMetadata(.update))
		Analytics.triggerAnalyticsSubmission(completion: { result in
			switch result {
			case .success:
				Log.info("[ENATaskExecutionDelegate] Analytics submission was triggered successfully from background", log: .ppa)
			case let .failure(error):
				Log.error("[ENATaskExecutionDelegate] Analytics submission was triggered not successfully from background with error: \(error)", log: .ppa, error: error)
			}
			completion()
		})
	}
}
