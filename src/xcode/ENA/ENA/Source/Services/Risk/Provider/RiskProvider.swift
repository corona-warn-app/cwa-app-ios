//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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
import ExposureNotification
import UIKit
import Combine

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (Result<ENExposureDetectionSummary, ExposureDetection.DidEndPrematurelyReason>) -> Void
	func detectExposure(
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping Completion
	) -> CancellationToken
}

final class RiskProvider {

	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let targetQueue: DispatchQueue
	private var consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")
	private var cancellationToken: CancellationToken?
	private let riskCalculation: RiskCalculationProtocol
	private var keyPackageDownload: KeyPackageDownloadProtocol

	private var _consumers: [RiskConsumer] = []
	private var consumers: [RiskConsumer] {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		exposureSummaryProvider: ExposureSummaryProvider,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		riskCalculation: RiskCalculationProtocol = RiskCalculation(),
		keyPackageDownload: KeyPackageDownloadProtocol
	) {
		self.configuration = configuration
		self.store = store
		self.exposureSummaryProvider = exposureSummaryProvider
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
		self.riskCalculation = riskCalculation
		self.keyPackageDownload = keyPackageDownload

		self.registerForPackageDownloadStatusUpdate()
	}

	// MARK: Properties
	private var subscriptions = Set<AnyCancellable>()
	private let store: Store
	private let exposureSummaryProvider: ExposureSummaryProvider
	private let appConfigurationProvider: AppConfigurationProviding
	private(set) var activityState: ActivityState = .idle
	var exposureManagerState: ExposureManagerState
	var configuration: RiskProvidingConfiguration
}

private extension RiskConsumer {
	func provideRiskCalculationResult(_ result: RiskCalculationResult) {
		switch result {
		case .success(let risk):
			targetQueue.async { [weak self] in
				self?.didCalculateRisk(risk)
			}
		case .failure(let error):
			targetQueue.async { [weak self] in
				self?.didFailCalculateRisk(error)
			}
		}
	}
}

extension RiskProvider: RiskProviding {

	func observeRisk(_ consumer: RiskConsumer) {
		consumers.append(consumer)
	}

	func removeRisk(_ consumer: RiskConsumer) {
		consumers.removeAll(where: { $0 === consumer })
	}

	var manualExposureDetectionState: ManualExposureDetectionState? {
		configuration.manualExposureDetectionState(
			activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
			lastExposureDetectionDate: store.summary?.date)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk(userInitiated: Bool, ignoreCachedSummary: Bool = false, completion: Completion? = nil) {
		Log.info("RiskProvider: Request risk was called. UserInitiated: \(userInitiated), ignoreCachedSummary: \(ignoreCachedSummary)", log: .riskDetection)

		guard activityState == .idle else {
			Log.info("RiskProvider: Risk detection is allready running. Don't start new risk detection.", log: .riskDetection)
			targetQueue.async {
				completion?(.failure(.riskProviderIsRunning))
			}
			return
		}

		queue.async {
			self.updateActivityState(.riskRequested)

			#if DEBUG
			if isUITesting {
				self._requestRiskLevel_Mock(userInitiated: userInitiated, completion: completion)
				return
			}
			#endif

			// Erase optionality.
			let completion: Completion = { result in
				completion?(result)
			}

			self._requestRiskLevel(userInitiated: userInitiated, ignoreCachedSummary: ignoreCachedSummary, completion: completion)
		}
	}

	/// Returns the next possible date of a exposureDetection
	/// Case1: Date is a valid date in the future
	/// Case2: Date is in the past (could be .distantPast) (usually happens when no detection has been run before (e.g. fresh install).
	/// For Case2, we need to calculate the remaining time until we reach a full 24h of tracing.
	func nextExposureDetectionDate() -> Date {
		let nextDate = configuration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.summary?.date
		)
		switch nextDate {
		case .now:  // Occurs when no detection has been performed ever
			let tracingHistory = store.tracingStatusHistory
			let numberOfEnabledSeconds = tracingHistory.activeTracing().interval
			let remainingTime = TracingStatusHistory.minimumActiveSeconds - numberOfEnabledSeconds
			// To get a more robust Date when calculating the Date we need to drop precision, otherwise we will get dates differing in miliseconds
			let timeInterval = Date().addingTimeInterval(remainingTime).timeIntervalSinceReferenceDate
			let timeIntervalInSeconds = Int(timeInterval)
			return Date(timeIntervalSinceReferenceDate: TimeInterval(timeIntervalInSeconds))
		case .date(let date):
			return date
		}
	}

	private func successOnTargetQueue(risk: Risk, completion: @escaping Completion) {
		Log.info("RiskProvider: Risk detection and calculation was successful.", log: .riskDetection)

		updateActivityState(.idle)

		targetQueue.async {
			completion(.success(risk))
		}

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}
	}

	private func failOnTargetQueue(error: RiskProviderError, completion: @escaping Completion) {
		Log.info("RiskProvider: Failed with error: \(error)", log: .riskDetection)

		updateActivityState(.idle)

		targetQueue.async {
			completion(.failure(error))
		}

		for consumer in consumers {
			_provideRiskResult(.failure(error), to: consumer)
		}
	}

	private func _requestRiskLevel(userInitiated: Bool, ignoreCachedSummary: Bool, completion: @escaping Completion) {
		let group = DispatchGroup()
		group.enter()
		
		var summary: SummaryMetadata?
		var appConfiguration: SAP_Internal_ApplicationConfiguration?
		
		appConfigurationProvider.appConfiguration { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let _config):
				appConfiguration = _config

				self.downloadKeyPackages { [weak self] result in
					guard let self = self else { return }

					switch result {
					case .success:
						if let risk = self.riskForMissingPreconditions() {
							self.successOnTargetQueue(risk: risk, completion: completion)
							group.leave()
							return
						}

						self.determineSummary(
							userInitiated: userInitiated,
							ignoreCachedSummary: ignoreCachedSummary,
							appConfiguration: _config,
							completion: { [weak self] result in
								switch result {
								case .success(let _summary):
									summary = _summary
								case .failure(let error):
									self?.failOnTargetQueue(error: error, completion: completion)
								}

								group.leave()
							}
						)

					case .failure(let error):
						self.failOnTargetQueue(error: error, completion: completion)
						group.leave()
					}
				}

			case .failure(let error):
				print("*** error: \(error)")
				self.failOnTargetQueue(error: .missingAppConfig, completion: completion)
				group.leave()
			}
		}

		guard group.wait(timeout: .now() + .seconds(60 * 8)) == .success else {
			updateActivityState(.idle)

			cancellationToken?.cancel()
			cancellationToken = nil
			Log.info("RiskProvider: Canceled risk calculation due to timeout", log: .riskDetection)
			failOnTargetQueue(error: .timeout, completion: completion)
			return
		}

		cancellationToken = nil

		guard summary != nil else {
			// Dont call failOnTargetQueue(...).
			// Summary can be nil at this point, when a risk was derived from cache.
			Log.info("RiskProvider: Failed risk level calculation. Summary is missing.", log: .riskDetection)
			return
		}

		self.calculateRiskLevel(
			summary: summary,
			appConfiguration: appConfiguration,
			completion: completion
		)
	}

	private func downloadKeyPackages(completion: @escaping (Result<Void, RiskProviderError>) -> Void) {
		// The result of a hour package download is not handled, because for the risk detection it is irrelevant if it fails or not.
		self.downloadHourPackages { [weak self] in
			guard let self = self else { return }

			self.downloadDayPackages(completion: { result in
				completion(result)
			})
		}
	}

	private func downloadDayPackages(completion: @escaping (Result<Void, RiskProviderError>) -> Void) {
		keyPackageDownload.startDayPackagesDownload(completion: { result in
			switch result {
			case .success:
				completion(.success(()))
			case .failure(let error):
				completion(.failure(.failedKeyPackageDownload(error)))
			}
		})
	}

	private func downloadHourPackages(completion: @escaping () -> Void) {
		keyPackageDownload.startHourPackagesDownload(completion: { _ in
			completion()
		})
	}

	private func riskForMissingPreconditions() -> Risk? {
		let tracingHistory = self.store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.activeTracing().inHours

		let details = Risk.Details(
			daysSinceLastExposure: self.store.summary?.summary.daysSinceLastExposure,
			numberOfExposures: Int(self.store.summary?.summary.matchedKeyCount ?? 0),
			activeTracing: tracingHistory.activeTracing(),
			exposureDetectionDate: self.store.summary?.date
		)

		// Risk Calculation involves some potentially long running tasks, like exposure detection and
		// fetching the configuration from the backend.
		// However in some precondition cases we can return early, mainly:
		// 1. The exposureManagerState is bad (turned off, not authorized, etc.)
		// 2. Tracing has not been active for at least 24 hours
		guard self.exposureManagerState.isGood else {
			return Risk(
				level: .inactive,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		guard numberOfEnabledHours >= TracingStatusHistory.minimumActiveHours else {
			return Risk(
				level: .unknownInitial,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		return nil
	}

	private func determineSummary(
		userInitiated: Bool,
		ignoreCachedSummary: Bool = false,
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping (Result<SummaryMetadata, RiskProviderError>) -> Void
	) {
		Log.info("RiskProvider: Determine summeries.", log: .riskDetection)
		
		if !ignoreCachedSummary {
			// Here we are in automatic mode and thus we have to check the validity of the current summary.
			let enoughTimeHasPassed = configuration.shouldPerformExposureDetection(
				activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
				lastExposureDetectionDate: store.summary?.date
			)
			let shouldDetectExposures = (configuration.detectionMode == .manual && userInitiated) || configuration.detectionMode == .automatic

			if !enoughTimeHasPassed || !self.exposureManagerState.isGood || !shouldDetectExposures {
				if let summary = store.summary {
					completion(.success(summary))
				} else {
					completion(.failure(.missingCachedSummary))
				}
				return
			}
		}

		self.updateActivityState(.detecting)

		// The summary is outdated: do a exposure detection
		self.cancellationToken = exposureSummaryProvider.detectExposure(appConfiguration: appConfiguration) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let detectedSummary):
				let summary = SummaryMetadata(detectionSummary: detectedSummary, date: Date())
				self.store.summary = summary

				/// We were able to calculate a risk so we have to reset the deadman notification
				UNUserNotificationCenter.current().resetDeadmanNotification()
				completion(.success(summary))
			case .failure(let error):
				completion(.failure(.failedRiskDetection(error)))
			}

			self.cancellationToken = nil
		}
	}

	private func calculateRiskLevel(summary: SummaryMetadata?, appConfiguration: SAP_Internal_ApplicationConfiguration?, completion: @escaping Completion) {
		Log.info("RiskProvider: Calculate risk level", log: .riskDetection)

		guard let appConfiguration = appConfiguration else {
			failOnTargetQueue(error: .missingAppConfig, completion: completion)
			return
		}

		let activeTracing = store.tracingStatusHistory.activeTracing()

		guard
			let risk = riskCalculation.risk(
				summary: summary?.summary,
				configuration: appConfiguration,
				dateLastExposureDetection: summary?.date,
				activeTracing: activeTracing,
				preconditions: exposureManagerState,
				previousRiskLevel: store.previousRiskLevel,
				providerConfiguration: configuration
			) else {
			Log.error("Serious error during risk calculation", log: .riskDetection)
			failOnTargetQueue(error: .failedRiskCalculation, completion: completion)
			return
		}

		/// Only set shouldShowRiskStatusLoweredAlert if risk level has changed from increase to low or vice versa. Otherwise leave shouldShowRiskStatusLoweredAlert unchanged.
		/// Scenario: Risk level changed from increased to low in the first risk calculation. In a second risk calculation it stays low. If the user does not open the app between these two calculations, the alert should still be shown.
		if risk.riskLevelHasChanged {
			switch risk.level {
			case .low:
				store.shouldShowRiskStatusLoweredAlert = true
			case .increased:
				store.shouldShowRiskStatusLoweredAlert = false
			default:
				break
			}
		}

		successOnTargetQueue(risk: risk, completion: completion)
		savePreviousRiskLevel(risk)

		/// We were able to calculate a risk so we have to reset the DeadMan Notification
		UNUserNotificationCenter.current().resetDeadmanNotification()
	}

	private func _provideRiskResult(_ result: RiskCalculationResult, to consumer: RiskConsumer?) {
		#if DEBUG
		if isUITesting {
			consumer?.provideRiskCalculationResult(.success(.mocked))
			return
		}
		#endif

		consumer?.provideRiskCalculationResult(result)
	}

	private func savePreviousRiskLevel(_ risk: Risk) {
		switch risk.level {
		case .low:
			store.previousRiskLevel = .low
		case .increased:
			store.previousRiskLevel = .increased
		default:
			break
		}
	}

	private func updateActivityState(_ state: ActivityState) {
		Log.info("RiskProvider: Update activity state to: \(state)", log: .riskDetection)

		self.activityState = state

		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeActivityState?(state)
			}
		}
	}

	private func registerForPackageDownloadStatusUpdate() {
		self.keyPackageDownload.statusDidChange = { [weak self] downloadStatus in
			guard let self = self else { return }

			switch downloadStatus {
			case .downloading:
				self.updateActivityState(.downloading)
			default:
				break
			}
		}
	}
}

extension RiskProvider {
	enum ActivityState {
		case idle
		case riskRequested
		case downloading
		case detecting

		var isActive: Bool {
			self == .downloading || self == .detecting
		}
	}
}

#if DEBUG
extension RiskProvider {
	private func _requestRiskLevel_Mock(userInitiated: Bool, completion: Completion? = nil) {
		// Erase optionality.
		let completion: Completion = { result in
			completion?(result)
		}

		let risk = Risk.mocked
		successOnTargetQueue(risk: risk, completion: completion)

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}

		savePreviousRiskLevel(risk)
	}
}
#endif
