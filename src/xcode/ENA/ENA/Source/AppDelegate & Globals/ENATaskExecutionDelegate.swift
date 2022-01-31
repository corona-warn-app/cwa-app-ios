//
// 🦠 Corona-Warn-App
//

import BackgroundTasks
import UIKit
import HealthCertificateToolkit
import OpenCombine

class TaskExecutionHandler: ENATaskExecutionDelegate {

	// MARK: - Init

	init(
		riskProvider: RiskProvider,
		restServiceProvider: RestServiceProviding,
		exposureManager: ExposureManager,
		plausibleDeniabilityService: PlausibleDeniabilityService,
		contactDiaryStore: DiaryStoring,
		eventStore: EventStoring,
		eventCheckoutService: EventCheckoutService,
		store: Store,
		exposureSubmissionDependencies: ExposureSubmissionServiceDependencies,
		healthCertificateService: HealthCertificateService
	) {
		self.riskProvider = riskProvider
		self.restServiceProvider = restServiceProvider
		self.exposureManager = exposureManager
		self.plausibleDeniabilityService = plausibleDeniabilityService
		self.contactDiaryStore = contactDiaryStore
		self.eventStore = eventStore
		self.eventCheckoutService = eventCheckoutService
		self.store = store
		self.dependencies = exposureSubmissionDependencies
		self.healthCertificateService = healthCertificateService
	}


	// MARK: - Protocol ENATaskExecutionDelegate

	var plausibleDeniabilityService: PlausibleDeniability
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
		Log.info("Starting background task...", log: .background)

		guard store.isOnboarded else {
			Log.info("Cancelling background task because user is not onboarded yet.", log: .background)

			completion(true)
			return
		}

		let group = DispatchGroup()

		group.enter()
		DispatchQueue.global().async {
			Log.info("Starting ExposureDetection...", log: .background)
			self.executeExposureDetectionRequest { _ in
				Log.info("Done detecting Exposures…", log: .background)
				
				/// ExposureDetection should be our highest Priority if we run all other tasks simultaneously we might get killed by the Watchdog while the Detection is running.
				/// This could leave us in a dirty state which causes the ExposureDetection to run too often. This will then lead to Error 13. (https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-5836)
				group.enter()
				DispatchQueue.global().async {
					Log.info("Trying to submit TEKs...", log: .background)
					self.executeSubmitTemporaryExposureKeys { _ in
						group.leave()
						Log.info("Done submitting TEKs...", log: .background)
					}
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Trying to fetch TestResults...", log: .background)
					self.executeFetchTestResults { _ in
						group.leave()
						Log.info("Done fetching TestResults...", log: .background)
					}
				}

				group.enter()
				DispatchQueue.global().async {
					Log.info("Starting FakeRequests...", log: .background)
					self.plausibleDeniabilityService.executeFakeRequests {
						group.leave()
						Log.info("Done sending FakeRequests...", log: .background)
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
				group.enter()
				DispatchQueue.global().async {
					Log.info("Check for invalid certificates", log: .background)
					self.checkCertificateValidityStates {
						group.leave()
						Log.info("Done checking for invalid certificates.", log: .background)
					}
				}
				
				group.enter()
				DispatchQueue.global().async {
					Log.info("Check if Booster Notifications need to be downloaded.", log: .background)
					self.executeBoosterNotificationsCreation {
						group.leave()
						Log.info("Done Checking if Booster Notifications should download …", log: .background)
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

	private let exposureManager: ExposureManager
	private let restServiceProvider: RestServiceProviding
	private let backgroundTaskConsumer = RiskConsumer()
	private let eventStore: EventStoring
	private let eventCheckoutService: EventCheckoutService
	private let healthCertificateService: HealthCertificateService
	private var subscriptions = Set<AnyCancellable>()

	/// This method attempts a submission of temporary exposure keys. The exposure submission service itself checks
	/// whether a submission should actually be executed.
	private func executeSubmitTemporaryExposureKeys(completion: @escaping ((Bool) -> Void)) {
		Log.info("[ENATaskExecutionDelegate] Attempt submission of temporary exposure keys.", log: .api)

		let service = ENAExposureSubmissionService(
			diagnosisKeysRetrieval: dependencies.exposureManager,
			appConfigurationProvider: dependencies.appConfigurationProvider,
			client: dependencies.client,
			restServiceProvider: restServiceProvider,
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
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, coronaTestType)))
					Log.info("[ENATaskExecutionDelegate] Submission: no corona test of type \(coronaTestType) registered", log: .api)
				case .noSubmissionConsent:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, coronaTestType)))
					Log.info("[ENATaskExecutionDelegate] Submission: no consent given", log: .api)
				case .noKeysCollected:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, coronaTestType)))
					Log.info("[ENATaskExecutionDelegate] Submission: no keys to submit", log: .api)
				case .some(let error):
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(false, coronaTestType)))
					Log.error("[ENATaskExecutionDelegate] Submission error: \(error.localizedDescription)", log: .api)
				case .none:
					Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true, coronaTestType)))
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
		UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
			if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
				self?.dependencies.coronaTestService.updateTestResults(force: false, presentNotification: true) { result in
					switch result {
					case .success:
						completion(true)
					case .failure:
						completion(false)
					}
				}
			} else {
				Log.info("[ENATaskExecutionDelegate] Cancel updating test results. User deactivated notification setting.", log: .riskDetection)
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

		if exposureManager.exposureManagerState.status == .unknown {
			exposureManager.activate { [weak self] error in
				if let error = error {
					Log.error("[ENATaskExecutionDelegate] Cannot activate the ENManager.", log: .api, error: error)
				}

				self?.riskProvider.requestRisk(userInitiated: false)
			}
		} else {
			riskProvider.requestRisk(userInitiated: false)
		}
	}

	private func executeAnalyticsSubmission(completion: @escaping () -> Void) {
		// update the enf risk exposure metadata and checkin risk exposure metadata if new risk calculations are not done in the meanwhile
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

	private func executeBoosterNotificationsCreation(completion: @escaping () -> Void) {
		Log.info("Checking if Booster rules need to be downloaded...", log: .vaccination)
		healthCertificateService.checkForConfigurationAndRulesUpdates { errorMessage in
			guard let errorMessage = errorMessage else {
				return
			}
			Log.error(errorMessage, log: .vaccination, error: nil)
		}
		completion()
	}

	private func checkCertificateValidityStates(completion: @escaping () -> Void) {
		healthCertificateService.updateValidityStatesAndNotificationsWithFreshDSCList(shouldScheduleTimer: false, completion: completion)
	}
}
