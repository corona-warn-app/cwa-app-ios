//
// 🦠 Corona-Warn-App
//

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
		exposureSubmissionService: ExposureSubmissionService,
		warnOthersReminder: WarnOthersReminder
	) {
		self.homeViewController = homeViewController
		self.state = state
		self.exposureSubmissionService = exposureSubmissionService
		self.warnOthersReminder = warnOthersReminder

		self.riskProviderActivityState = riskProvider.activityState

		observeRisk()
	}

	// MARK: Properties
	private(set) var state: State {
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
	private let warnOthersReminder: WarnOthersReminder

	var enStateHandler: ENStateHandler?

	private var detectionMode: DetectionMode { state.detectionMode }
	private(set) var sections: SectionConfiguration = []

	private var activeConfigurator: HomeActivateCellConfigurator?
	private var testResultConfigurator = HomeTestResultCellConfigurator()
	private var riskLevelConfigurator: HomeRiskLevelCellConfigurator?
	private var failedConfigurator: HomeFailedCellConfigurator?

	private var countdownTimer: CountdownTimer?

	private(set) var testResult: TestResult?

	private var riskProviderActivityState: RiskProviderActivityState = .idle

	private let riskConsumer = RiskConsumer()

	deinit {
		riskProvider.removeRisk(riskConsumer)
	}

	private func updateActiveCell() {
		guard let indexPath = indexPathForActiveCell() else { return }
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func updateRiskButton(isEnabled: Bool) {
		riskLevelConfigurator?.updateButtonEnabled(isEnabled)
	}

	private func updateRiskButton(isHidden: Bool) {
		riskLevelConfigurator?.updateButtonHidden(isHidden)
	}

	private func reloadRiskOrFailedCell() {
		guard let indexPath = indexPathForRiskOrFailedCell() else { return }
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func observeRisk() {
		riskConsumer.didChangeActivityState = { [weak self] state in
			self?.updateAndReloadRiskCellState(to: state)
		}

		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.state.riskState = .risk(risk)
			self?.reloadActionSection()
		}

		riskConsumer.didFailCalculateRisk = { [weak self] error in
			guard let self = self else { return }

			// Don't show already running errors.
			guard !error.isAlreadyRunningError else {
				Log.info("[HomeInteractor] Ignore already running error.", log: .riskDetection)
				return
			}

			guard error.shouldBeDisplayedToUser else {
				Log.info("[HomeInteractor] Don't show error to user: \(error).", log: .riskDetection)
				return
			}

            switch error {
            case .inactive:
				self.state.riskState = .inactive
            default:
				self.state.riskState = .detectionFailed
            }

			self.reloadActionSection()
		}

		riskProvider.observeRisk(riskConsumer)
	}

	func updateDetectionMode(_ detectionMode: DetectionMode) {
		state.detectionMode = detectionMode
	}

	func updateExposureManagerState(_ exposureManagerState: ExposureManagerState) {
		state.exposureManagerState = exposureManagerState
	}

	func updateAndReloadRiskCellState(to state: RiskProviderActivityState) {
		Log.info("[HomeInteractor] Update and reload risk cell with state: \(state)")
		riskProviderActivityState = state
		riskLevelConfigurator?.riskProviderState = state
		failedConfigurator?.riskProviderState = state
		reloadRiskOrFailedCell()
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
	private var riskDetails: Risk.Details? { state.riskDetails }

	func setupRiskConfigurator() -> CollectionViewCellConfiguratorAny? {
		let detectionIsAutomatic = detectionMode == .automatic
		let dateLastExposureDetection = riskDetails?.exposureDetectionDate

		let detectionInterval = riskProvider.riskProvidingConfiguration.exposureDetectionInterval.hour ?? RiskProvidingConfiguration.defaultExposureDetectionsInterval

		let riskState: RiskState = state.exposureManagerState.enabled ? state.riskState : .inactive

		switch riskState {
		case .inactive:
			let inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				inactiveType: .noCalculationPossible,
				previousRiskLevel: store.riskCalculationResult?.riskLevel,
				lastUpdateDate: dateLastExposureDetection
			)
			inactiveConfigurator.activeAction = { [weak self] in
				self?.homeViewController.showExposureNotificationSetting()
			}

			return inactiveConfigurator
		case .detectionFailed:
			let _failedConfigurator = HomeFailedCellConfigurator(
				state: riskProviderActivityState,
				previousRiskLevel: store.riskCalculationResult?.riskLevel,
				lastUpdateDate: dateLastExposureDetection
			)
			_failedConfigurator.activeAction = { [weak self] in
				guard let self = self else { return }
				self.requestRisk(userInitiated: true)
			}
			
			failedConfigurator = _failedConfigurator

			return _failedConfigurator
		case .risk(let risk) where risk.level == .low:
			riskLevelConfigurator = HomeLowRiskCellConfigurator(
				state: riskProviderActivityState,
				numberOfDaysWithLowRisk: risk.details.numberOfDaysWithRiskLevel,
				lastUpdateDate: dateLastExposureDetection,
				isButtonHidden: detectionIsAutomatic,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionInterval: detectionInterval,
				activeTracing: risk.details.activeTracing
			)
		case .risk(let risk) where risk.level == .high:
			riskLevelConfigurator = HomeHighRiskCellConfigurator(
				state: riskProviderActivityState,
				numberOfDaysWithHighRisk: risk.details.numberOfDaysWithRiskLevel,
				mostRecentDateWithHighRisk: risk.details.mostRecentDateWithRiskLevel,
				lastUpdateDate: dateLastExposureDetection,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionMode: detectionMode,
				detectionInterval: detectionInterval
			)
		case .risk:
			fatalError("The risk level has to be either .low or .high")
		}

		riskLevelConfigurator?.buttonAction = { [weak self] in
			self?.requestRisk(userInitiated: true)
		}

		return riskLevelConfigurator
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

	func setupDiaryConfigurator() -> HomeDiaryCellConfigurator {
		let diaryConfigurator = HomeDiaryCellConfigurator()
		diaryConfigurator.primaryAction = homeViewController.showDiary
		return diaryConfigurator
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
		let _activeConfigurator = setupActiveConfigurator()
		_activeConfigurator.updateEnState(state.enState)
		actionsConfigurators.append(_activeConfigurator)
		activeConfigurator = _activeConfigurator

		// MARK: - Add cards depending on result state.

		if store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil {
			// This is shown when we submitted keys! (Positive test result + actually decided to submit keys.)
			// Once this state is reached, it cannot be left anymore.

			let thankYou = HomeThankYouRiskCellConfigurator()
			actionsConfigurators.append(thankYou)
			Log.info("Reached end of life state.", log: .localData)

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

			case .positive where warnOthersReminder.positiveTestResultWasShown:
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

		let diaryConfigurator = setupDiaryConfigurator()
		actionsConfigurators.append(diaryConfigurator)

		return actionsConfigurators
	}

	private func setupActionSectionDefinition() -> SectionDefinition {
		return (.actions, setupActionConfigurators())
	}
}

// MARK: - IndexPath helpers.

extension HomeInteractor {

	private func indexPathForRiskOrFailedCell() -> IndexPath? {
		for section in sections {
			let index = section.cellConfigurators.firstIndex { cellConfigurator in
				cellConfigurator === self.riskLevelConfigurator || cellConfigurator is HomeFailedCellConfigurator
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

			case .success(let testResult):
				switch testResult {
				case .expired:
					self?.homeViewController.alertError(
						message: AppStrings.ExposureSubmissionResult.testExpiredDesc,
						title: AppStrings.Home.resultCardLoadingErrorTitle,
						completion: {
							self?.testResult = .expired
							self?.reloadTestResult(with: .invalid)
						}
					)
				case .invalid, .negative, .positive, .pending:
					let requestTime = Date().timeIntervalSince(requestStart)
					let delay = requestTime < minRequestTime && self?.testResult == nil ? minRequestTime : 0
					DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
						self?.testResult = testResult
						self?.reloadTestResult(with: testResult)
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
		activeConfigurator?.updateEnState(state)
		updateActiveCell()
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
		countdownTimer = CountdownTimer(countdownTo: riskProvider.nextExposureDetectionDate)
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
		guard let indexPath = self.indexPathForRiskOrFailedCell() else { return }
		guard let cell = homeViewController.cellForItem(at: indexPath) as? RiskLevelCollectionViewCell else { return }

		// We pass the time and let the configurator decide whether the button can be activated or not.
		riskLevelConfigurator?.timeUntilUpdate = time
		riskLevelConfigurator?.configureButton(for: cell)
	}
	
	func refreshTimerAfterResumingFromBackground() {
		scheduleCountdownTimer()
	}
}
