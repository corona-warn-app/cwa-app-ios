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

import ExposureNotification
import Foundation
import UIKit

final class HomeInteractor: RequiresAppDependencies {
	typealias SectionDefinition = (section: HomeViewController.Section, cellConfigurators: [CollectionViewCellConfiguratorAny])
	typealias SectionConfiguration = [SectionDefinition]

	// MARK: Creating

	init(
		homeViewController: HomeViewController,
		state: State,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.homeViewController = homeViewController
		self.state = state
		self.exposureSubmissionService = exposureSubmissionService
		observeRisk()
	}

	// MARK: Properties
	var state: State {
		didSet {
			if state != oldValue {
				homeViewController.setStateOfChildViewControllers()
				// `buildSections()` has to be called prior to `scheduleCountdownTimer()`
				// because `scheduleCountdownTimer()` relies on the sections to be already built.
				buildSections()
				scheduleCountdownTimer()
			}
		}
	}

	private unowned var homeViewController: HomeViewController
	private let exposureSubmissionService: ExposureSubmissionService
	var enStateHandler: ENStateHandler?

	private var detectionMode: DetectionMode { state.detectionMode }
	private(set) var sections: SectionConfiguration = []

	private var activeConfigurator: HomeActivateCellConfigurator!
	private var testResultConfigurator = HomeTestResultCellConfigurator()
	private var riskLevelConfigurator: HomeRiskLevelCellConfigurator?
	private var inactiveConfigurator: HomeInactiveRiskCellConfigurator?
	private var countdownTimer: CountdownTimer?

	private(set) var testResult: TestResult?

	private lazy var isRequestRiskRunning = riskProvider.isLoading
	private let riskConsumer = RiskConsumer()

	deinit {
		riskProvider.removeRisk(riskConsumer)
	}

	private func updateActiveCell() {
		guard let indexPath = indexPathForActiveCell() else { return }
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func updateRiskLoading() {
		isRequestRiskRunning ? riskLevelConfigurator?.startLoading() : riskLevelConfigurator?.stopLoading()
	}

	private func updateRiskButton(isEnabled: Bool) {
		riskLevelConfigurator?.updateButtonEnabled(isEnabled)
	}

	private func updateRiskButton(isHidden: Bool) {
		riskLevelConfigurator?.updateButtonHidden(isHidden)
	}

	private func reloadRiskCell() {
		guard let indexPath = indexPathForRiskCell() else { return }
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func observeRisk() {
		riskConsumer.didChangeLoadingStatus = { isLoading in
			self.updateAndReloadRiskLoading(isRequestRiskRunning: isLoading)
		}

		riskProvider.observeRisk(riskConsumer)
	}

	func updateAndReloadRiskLoading(isRequestRiskRunning: Bool) {
		self.isRequestRiskRunning = isRequestRiskRunning
		updateRiskLoading()
		reloadRiskCell()
	}

	func requestRisk(userInitiated: Bool) {
		riskProvider.requestRisk(userInitiated: userInitiated)
	}

	func buildSections() {
		sections = initialCellConfigurators()
	}

	private func initialCellConfigurators() -> SectionConfiguration {

		let info1Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardShareTitle,
			description: AppStrings.Home.infoCardShareBody,
			position: .first,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.infoCardShareTitle
		)

		let info2Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardAboutTitle,
			description: AppStrings.Home.infoCardAboutBody,
			position: .last,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.infoCardAboutTitle
		)

		let appInformationConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.appInformationCardTitle,
			description: nil,
			position: .first,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.appInformationCardTitle
		)

		let settingsConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.settingsCardTitle,
			description: nil,
			position: .last,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.settingsCardTitle
		)

		let infosConfigurators: [CollectionViewCellConfiguratorAny] = [info1Configurator, info2Configurator]
		let settingsConfigurators: [CollectionViewCellConfiguratorAny] = [appInformationConfigurator, settingsConfigurator]

		let actionsSection: SectionDefinition = setupActionSectionDefinition()
		let infoSection: SectionDefinition = (.infos, infosConfigurators)
		let settingsSection: SectionDefinition = (.settings, settingsConfigurators)

		var sections: [(section: HomeViewController.Section, cellConfigurators: [CollectionViewCellConfiguratorAny])] = []
		sections.append(contentsOf: [actionsSection, infoSection, settingsSection])

		return sections
	}
}

// MARK: - Test result cell methods.

extension HomeInteractor {

	private func reloadTestResult(with result: TestResult) {
		testResultConfigurator.testResult = result
		reloadActionSection()
		guard let indexPath = indexPathForTestResultCell() else { return }
		homeViewController.reloadCell(at: indexPath)
	}

	func reloadActionSection() {
		precondition(
			!sections.isEmpty,
			"Serious programmer error: reloadActionSection() was called without calling buildSections() first."
		)
		sections[0] = setupActionSectionDefinition()
		homeViewController.reloadData(animatingDifferences: false)
	}
}

// MARK: - Action section setup helpers.

extension HomeInteractor {
	private var risk: Risk? { state.risk }
	private var riskDetails: Risk.Details? { risk?.details }

	// swiftlint:disable:next function_body_length
	func setupRiskConfigurator() -> CollectionViewCellConfiguratorAny? {

		let detectionIsAutomatic = detectionMode == .automatic
		let dateLastExposureDetection = riskDetails?.exposureDetectionDate

		riskLevelConfigurator = nil
		inactiveConfigurator = nil

		let detectionInterval = (riskProvider.configuration.exposureDetectionInterval.day ?? 1) * 24

		let riskLevel: RiskLevel? = state.exposureManagerState.enabled ? state.riskLevel : .inactive

		switch riskLevel {
		case .unknownInitial:
			riskLevelConfigurator = HomeUnknownRiskCellConfigurator(
				isLoading: isRequestRiskRunning,
				lastUpdateDate: nil,
				detectionInterval: detectionInterval,
				detectionMode: detectionMode,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState
			)
		case .inactive:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				inactiveType: .noCalculationPossible,
				previousRiskLevel: store.previousRiskLevel,
				lastUpdateDate: dateLastExposureDetection
			)
			inactiveConfigurator?.activeAction = inActiveCellActionHandler
		case .unknownOutdated:
			if detectionMode == .automatic {
				inactiveConfigurator = HomeInactiveRiskCellConfigurator(
					inactiveType: .outdatedResults,
					previousRiskLevel: store.previousRiskLevel,
					lastUpdateDate: dateLastExposureDetection
				)
				inactiveConfigurator?.activeAction = inActiveCellActionHandler
			} else {
				riskLevelConfigurator = HomeUnknown48hRiskCellConfigurator(
					isLoading: isRequestRiskRunning,
					lastUpdateDate: dateLastExposureDetection,
					detectionInterval: detectionInterval,
					detectionMode: detectionMode,
					manualExposureDetectionState: riskProvider.manualExposureDetectionState,
					previousRiskLevel: store.previousRiskLevel)
			}
		case .low:
			let activeTracing = risk?.details.activeTracing ?? .init(interval: 0)
			riskLevelConfigurator = HomeLowRiskCellConfigurator(
				isLoading: isRequestRiskRunning,
				numberRiskContacts: state.numberRiskContacts,
				lastUpdateDate: dateLastExposureDetection,
				isButtonHidden: detectionIsAutomatic,
				detectionMode: detectionMode,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionInterval: detectionInterval,
				activeTracing: activeTracing
			)
		case .increased:
			riskLevelConfigurator = HomeHighRiskCellConfigurator(
				isLoading: isRequestRiskRunning,
				numberRiskContacts: state.numberRiskContacts,
				daysSinceLastExposure: state.daysSinceLastExposure,
				lastUpdateDate: dateLastExposureDetection,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionMode: detectionMode,
				detectionInterval: detectionInterval
			)
		case .none:
			riskLevelConfigurator = nil
		}

		riskLevelConfigurator?.buttonAction = {
			self.requestRisk(userInitiated: true)
		}
		return riskLevelConfigurator ?? inactiveConfigurator
	}

	private func setupTestResultConfigurator() -> HomeTestResultCellConfigurator {
		testResultConfigurator.primaryAction = homeViewController.showTestResultScreen
		return testResultConfigurator
	}

	func setupSubmitConfigurator() -> HomeTestResultCellConfigurator {
		let submitConfigurator = HomeTestResultCellConfigurator()
		submitConfigurator.primaryAction = homeViewController.showExposureSubmissionWithoutResult
		return submitConfigurator
	}

	func setupFindingPositiveRiskCellConfigurator() -> HomeFindingPositiveRiskCellConfigurator {
		let configurator = HomeFindingPositiveRiskCellConfigurator()
		configurator.nextAction = {
			self.homeViewController.showExposureSubmission(with: self.testResult)
		}
		return configurator
	}

	func setupActiveConfigurator() -> HomeActivateCellConfigurator {
		return HomeActivateCellConfigurator(state: state.enState)
	}

	func setupActionConfigurators() -> [CollectionViewCellConfiguratorAny] {
		var actionsConfigurators: [CollectionViewCellConfiguratorAny] = []

		// MARK: - Add cards that are always shown.

		// Active card.
		activeConfigurator = setupActiveConfigurator()
		actionsConfigurators.append(activeConfigurator)

		// MARK: - Add cards depending on result state.

		if store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil {
			// This is shown when we submitted keys! (Positive test result + actually decided to submit keys.)
			// Once this state is reached, it cannot be left anymore.

			let thankYou = HomeThankYouRiskCellConfigurator()
			actionsConfigurators.append(thankYou)
			log(message: "Reached end of life state.", file: #file, line: #line, function: #function)

		} else if store.registrationToken != nil {
			// This is shown when we registered a test.
			// Note that the `positive` state has a custom cell and the risk cell will not be shown once the user was tested positive.

			switch self.testResult {
			case .none:
				// Risk card.
				if let risk = setupRiskConfigurator() {
					actionsConfigurators.append(risk)
				}

				// Loading card.
				let testResultLoadingCellConfigurator = HomeTestResultLoadingCellConfigurator()
				actionsConfigurators.append(testResultLoadingCellConfigurator)

			case .positive:
				let findingPositiveRiskCellConfigurator = setupFindingPositiveRiskCellConfigurator()
				actionsConfigurators.append(findingPositiveRiskCellConfigurator)

			default:
				// Risk card.
				if let risk = setupRiskConfigurator() {
					actionsConfigurators.append(risk)
				}

				let testResultConfigurator = setupTestResultConfigurator()
				actionsConfigurators.append(testResultConfigurator)
			}
		} else {
			// This is the default view that is shown when no test results are available and nothing has been submitted.

			// Risk card.
			if let risk = setupRiskConfigurator() {
				actionsConfigurators.append(risk)
			}

			let submitCellConfigurator = setupSubmitConfigurator()
			actionsConfigurators.append(submitCellConfigurator)
		}

		return actionsConfigurators
	}

	private func setupActionSectionDefinition() -> SectionDefinition {
		return (.actions, setupActionConfigurators())
	}
}

// MARK: - IndexPath helpers.

extension HomeInteractor {

	private func indexPathForRiskCell() -> IndexPath? {
		for section in sections {
			let index = section.cellConfigurators.firstIndex { cellConfigurator in
				cellConfigurator === self.riskLevelConfigurator
			}
			guard let item = index else { return nil }
			let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
			return indexPath
		}
		return nil
	}

	private func indexPathForActiveCell() -> IndexPath? {
		for section in sections {
			let index = section.cellConfigurators.firstIndex { cellConfigurator in
				cellConfigurator === self.activeConfigurator
			}
			guard let item = index else { return nil }
			let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
			return indexPath
		}
		return nil
	}

	private func indexPathForTestResultCell() -> IndexPath? {
		let section = sections.first
		let index = section?.cellConfigurators.firstIndex { cellConfigurator in
			cellConfigurator === self.testResultConfigurator
		}
		guard let item = index else { return nil }
		let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
		return indexPath
	}
}

// MARK: - Exposure submission service calls.

extension HomeInteractor {
	func updateTestResults() {
		// Avoid unnecessary loading.
		guard testResult == nil || testResult != .positive else { return }
		guard store.registrationToken != nil else { return }

		// Make sure to make the loading cell appear for at least `minRequestTime`.
		// This avoids an ugly flickering when the cell is only shown for the fraction of a second.
		// Make sure to only trigger this additional delay when no other test result is present already.
		let requestStart = Date()
		let minRequestTime: TimeInterval = 0.5

		self.exposureSubmissionService.getTestResult { [weak self] result in
			switch result {
			case .failure(let error):
				// When we fail here, trigger an alert and set the state to pending.
				self?.homeViewController.alertError(
					message: error.localizedDescription,
					title: AppStrings.Home.resultCardLoadingErrorTitle,
					completion: {
						self?.testResult = .pending
						self?.reloadTestResult(with: .pending)
					}
				)

			case .success(let result):
				switch result {
				case .redeemed:
					self?.homeViewController.alertError(
						message: AppStrings.ExposureSubmissionResult.testRedeemedDesc,
						title: AppStrings.Home.resultCardLoadingErrorTitle,
						completion: {
							self?.testResult = .redeemed
							self?.reloadTestResult(with: .invalid)
						}
					)
				default:
					let requestTime = Date().timeIntervalSince(requestStart)
					let delay = requestTime < minRequestTime && self?.testResult == nil ? minRequestTime : 0
					DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
						self?.testResult = result
						self?.reloadTestResult(with: result)
					}
				}
			}
		}
	}
}

// MARK: The ENStateHandler updating
extension HomeInteractor: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		self.state.enState = state
		activeConfigurator.updateEnState(state)
		updateActiveCell()
	}
}

extension HomeInteractor {
	private func inActiveCellActionHandler() {
		homeViewController.showExposureNotificationSetting()
	}
}

// MARK: - CountdownTimerDelegate methods.

/// The `CountdownTimerDelegate` is used to update the remaining time that is shown on the risk cell button until a manual refresh is allowed.
extension HomeInteractor: CountdownTimerDelegate {
	private func scheduleCountdownTimer() {
		guard self.detectionMode == .manual else { return }

		// Cleanup potentially existing countdown.
		countdownTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)

		// Schedule new countdown.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateCountdownTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		let nextUpdate = self.riskProvider.nextExposureDetectionDate()
		countdownTimer = CountdownTimer(countdownTo: nextUpdate)
		countdownTimer?.delegate = self
		countdownTimer?.start()
	}

	@objc
	private func invalidateCountdownTimer() {
		countdownTimer?.invalidate()
	}

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		// Reload action section to trigger full refresh of the risk cell configurator (updates
		// the isButtonEnabled attribute).
		self.reloadActionSection()
	}

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		guard let indexPath = self.indexPathForRiskCell() else { return }
		guard let cell = homeViewController.cellForItem(at: indexPath) as? RiskLevelCollectionViewCell else { return }

		// We pass the time and let the configurator decide whether the button can be activated or not.
		riskLevelConfigurator?.timeUntilUpdate = time
		riskLevelConfigurator?.configureButton(for: cell)
	}
}
