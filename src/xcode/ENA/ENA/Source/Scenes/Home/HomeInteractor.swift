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

// swiftlint:disable:next type_body_length
final class HomeInteractor {

	typealias SectionDefinition = (section: HomeViewController.Section, cellConfigurators: [CollectionViewCellConfiguratorAny])
	typealias SectionConfiguration = [SectionDefinition]


	enum UserLoadingMode {
		case automatic
		case manual
	}

	// MARK: Creating

	init(
		homeViewController: HomeViewController,
		store: Store,
		state: State,
		exposureSubmissionService: ExposureSubmissionService? = nil,
		taskScheduler: ENATaskScheduler
	) {
		self.homeViewController = homeViewController
		self.store = store
		self.state = state
		self.taskScheduler = taskScheduler
		stateHandler = ENStateHandler(
			self.state.exposureManager,
			reachabilityService: ConnectivityReachabilityService(),
			delegate: self
		)
		sections = initialCellConfigurators()
	}

	// MARK: Properties

	var state = HomeInteractor.State(
		isLoading: false,
		summary: nil,
		exposureManager: .init()
	) {
		didSet {
			stateHandler.exposureManagerDidUpdate(to: state.exposureManager)
			homeViewController.setStateOfChildViewControllers(
				.init(
					exposureManager: state.exposureManager,
					summary: state.summary
				), stateHandler: stateHandler
			)
			reloadRiskCell()
			sections = initialCellConfigurators()
			homeViewController.reloadData()
		}
	}

	private unowned var homeViewController: HomeViewController
	private let store: Store
	private var exposureSubmissionService: ExposureSubmissionService?
	var stateHandler: ENStateHandler!
	private let taskScheduler: ENATaskScheduler
	private var riskLevel: RiskLevel {
		RiskLevel(riskScore: state.summary?.maximumRiskScore)
	}

	private(set) var sections: SectionConfiguration = []

	private var activeConfigurator: HomeActivateCellConfigurator!
	private var testResultConfigurator: HomeTestResultCellConfigurator?
	private var riskLevelConfigurator: HomeRiskLevelCellConfigurator?
	private var inactiveConfigurator: HomeInactiveRiskCellConfigurator?

	func developerMenuEnableIfAllowed() {}

	private let userLoadingMode = UserLoadingMode.manual // !

	private var isUpdateTaskRunning: Bool = false
	private var updateRiskTimer: Timer?
	private var isTimerRunning: Bool { updateRiskTimer?.isValid ?? false }
	private var releaseDate: Date?
	private var startDate: Date?
	private(set) var testResult: TestResult?


	private func riskCellTask(completion: @escaping (() -> Void)) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: completion)
	}

	private func startCheckRisk() {
		guard let indexPath = indexPathForRiskCell() else { return }
		riskLevelConfigurator?.startLoading()
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)

		taskScheduler.cancelAllBackgroundTaskRequests()

		riskCellTask(completion: {
			self.riskLevelConfigurator?.stopLoading()
			guard let indexPath = self.indexPathForRiskCell() else { return }
			self.homeViewController.updateSections()
			self.homeViewController.reloadCell(at: indexPath)
			self.taskScheduler.scheduleBackgroundTaskRequests()
		})
	}

	private func fetchUpdateRisk() {
		isUpdateTaskRunning = true
		reloadRiskCell()
		riskCellTask(completion: {
			self.isUpdateTaskRunning = false
			if self.userLoadingMode == .automatic, !self.isTimerRunning {
				self.startCountdownAndUpdateRisk()
			} else {
				self.reloadRiskCell()
			}
        })
	}

	func updateActiveCell() {
		guard let indexPath = indexPathForActiveCell() else { return }
		let currentState = stateHandler.getState()
		activeConfigurator.set(newState: currentState)
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func startCountdownAndUpdateRisk() {
		startCountdown()
		fetchUpdateRisk()
	}

	private func updateRiskLoading() {
		isUpdateTaskRunning ? riskLevelConfigurator?.startLoading() : riskLevelConfigurator?.stopLoading()
	}

	private func updateRiskCounter() {
		if let releaseDate = releaseDate, isTimerRunning {
			riskLevelConfigurator?.updateCounter(startDate: Date(), releaseDate: releaseDate)
		} else {
			riskLevelConfigurator?.removeCounter()
		}
	}

	private func updateRiskButton() {
		riskLevelConfigurator?.updateButtonEnabled(!isUpdateTaskRunning && !isTimerRunning)
	}

	private func reloadRiskCell() {
		guard let indexPath = indexPathForRiskCell() else { return }
		updateRiskLoading()
		updateRiskButton()
		updateRiskCounter()
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}


	private func initialCellConfigurators() -> SectionConfiguration {

		let info1Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardShareTitle,
			body: AppStrings.Home.infoCardShareBody,
			position: .first,
			accessibilityIdentifier: Accessibility.Cell.infoCardShareTitle
		)

		let info2Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardAboutTitle,
			body: AppStrings.Home.infoCardAboutBody,
			position: .last,
			accessibilityIdentifier: Accessibility.Cell.infoCardAboutTitle
		)

		let appInformationConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.appInformationCardTitle,
			body: nil,
			position: .first,
			accessibilityIdentifier: Accessibility.Cell.appInformationCardTitle
		)

		let settingsConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.settingsCardTitle,
			body: nil,
			position: .last,
			accessibilityIdentifier: Accessibility.Cell.settingsCardTitle
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

	// MARK: Timer

	private func startTimer() {
		let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
		updateRiskTimer = timer
		RunLoop.current.add(timer, forMode: .common)
		updateRiskTimer?.tolerance = 0.1
	}

	private func stopTimer() {
		updateRiskTimer?.invalidate()
		updateRiskTimer = nil
	}

	@objc
	private func fireTimer(timer _: Timer) {
		guard let releaseDate = releaseDate else { return }
		let now = Date()
		if now <= releaseDate {
			reloadRiskCell()
		} else {
			stopTimer()
			if userLoadingMode == .automatic, !isUpdateTaskRunning {
				startCountdownAndUpdateRisk()
			} else {
				reloadRiskCell()
			}
		}
	}

	private func startCountdown() {
		startDate = Date()
		releaseDate = calculateReleaseDate(from: startDate)
		startTimer()
	}

	private func calculateReleaseDate(from date: Date?) -> Date? {
		guard let date = date else { return nil }
		var dateComponents = DateComponents()
		dateComponents.second = 6
		let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
		return newDate
	}
}

// MARK: - Test result cell methods.

extension HomeInteractor {

	func reloadTestResult(with result: TestResult) {
		self.testResultConfigurator?.testResult = result
		reloadActionSection()
		guard let indexPath = indexPathForTestResultCell() else { return }
		homeViewController.reloadCell(at: indexPath)
	}

	func reloadActionSection() {
		sections[0] = setupActionSectionDefinition()
		homeViewController.updateSections()
		homeViewController.applySnapshotFromSections(animatingDifferences: true)
		homeViewController.reloadData()
	}
}

// MARK: - Action section setup helpers.

extension HomeInteractor {

	// swiftlint:disable:next function_body_length
	func setupRiskConfigurator() -> CollectionViewCellConfiguratorAny? {
		let dateLastExposureDetection = store.dateLastExposureDetection

		let isButtonHidden = userLoadingMode == .automatic
		let isCounterLabelHidden = !isButtonHidden

		if riskLevel != .inactive, userLoadingMode == .automatic {
			startCountdown()
		}

		switch riskLevel {
		case .unknownInitial, .unknownOutdated:
			riskLevelConfigurator = HomeUnknownRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				isButtonHidden: isButtonHidden,
				isCounterLabelHidden: isCounterLabelHidden,
				startDate: startDate,
				releaseDate: releaseDate,
				lastUpdateDate: nil
			)
		case .inactive:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(lastInvestigation: "Geringes Risiko", lastUpdateDate: dateLastExposureDetection)
		case .low:
			riskLevelConfigurator = HomeLowRiskCellConfigurator(
				startDate: startDate,
				releaseDate: releaseDate,
				numberDays: 2,
				totalDays: 14,
				lastUpdateDate: dateLastExposureDetection
			)
			riskLevelConfigurator?.isButtonHidden = isButtonHidden
			riskLevelConfigurator?.isCounterLabelHidden = isCounterLabelHidden
		case .increased:
			riskLevelConfigurator = HomeHighRiskCellConfigurator(
				startDate: startDate,
				releaseDate: releaseDate,
				numberRiskContacts: state.numberRiskContacts,
				daysSinceLastExposure: state.daysSinceLastExposure,
				lastUpdateDate: dateLastExposureDetection
			)
			riskLevelConfigurator?.isButtonHidden = isButtonHidden
			riskLevelConfigurator?.isCounterLabelHidden = isCounterLabelHidden
		}

		riskLevelConfigurator?.buttonAction = { [unowned self] in
			if self.riskLevel == .inactive {
				// go to settings?
			} else {
				self.startCountdownAndUpdateRisk()
			}
		}

		riskLevelConfigurator?.buttonAction = { [unowned self] in
			if self.riskLevel == .inactive {
				// go to settings?
			} else {
				self.startCountdownAndUpdateRisk()
			}
		}

		if let risk = riskLevelConfigurator {
			riskLevelConfigurator = risk
			return risk
		}

		if let inactive = inactiveConfigurator {
			inactiveConfigurator = inactive
			return inactive
		}

		return nil
	}

	func setupTestResultConfigurator() -> HomeTestResultCellConfigurator {
		guard let testResultConfigurator = self.testResultConfigurator else {
			self.testResultConfigurator = HomeTestResultCellConfigurator()
			// swiftlint:disable:next force_unwrapping
			return self.testResultConfigurator!
		}

		testResultConfigurator.buttonAction = { [weak self] in
			self?.homeViewController.showTestResultScreen()
		}

		return testResultConfigurator
	}

	func setupSubmitConfigurator() -> HomeSubmitCellConfigurator {
		let submitConfigurator = HomeSubmitCellConfigurator()
		submitConfigurator.submitAction = { [unowned self] in
			self.homeViewController.showExposureSubmission()
		}

		return submitConfigurator
	}

	func setupThankYouConfigurator() -> HomeThankYouRiskCellConfigurator {
		let configurator = HomeThankYouRiskCellConfigurator()
		return configurator
	}

	func setupFindingPositiveRiskCellConfigurator() -> HomeFindingPositiveRiskCellConfigurator {
		let configurator = HomeFindingPositiveRiskCellConfigurator()
		configurator.nextAction = {
			self.homeViewController.showExposureSubmission(with: self.testResult)
		}
		return configurator
	}

	func setupActiveConfigurator() -> HomeActivateCellConfigurator {
		let currentState = stateHandler.getState()
		return HomeActivateCellConfigurator(state: currentState)
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

			let thankYou = setupThankYouConfigurator()
			actionsConfigurators.append(thankYou)
			appLogger.log(message: "Reached end of life state.", file: #file, line: #line, function: #function)

		} else if store.registrationToken != nil {
			// This is shown when we registered a test.
			// Note that the `positive` state has a custom cell and the risk cell will not be shown once the user was tested positive.

			switch self.testResult {
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
			if let risk = setupRiskConfigurator() as? HomeRiskLevelCellConfigurator {
				actionsConfigurators.append(risk)
			}

			let submitCellConfigurator = setupSubmitConfigurator()
			actionsConfigurators.append(submitCellConfigurator)
		}

		return actionsConfigurators
	}

	func setupActionSectionDefinition() -> SectionDefinition {
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
		DispatchQueue.global(qos: .userInteractive).async {
			self.updateTestResultHelper()
		}
	}

	private func updateTestResultHelper() {
		guard store.registrationToken != nil else { return }

		self.exposureSubmissionService?.getTestResult { result in
			switch result {
			case .failure(let error):
				appLogger.log(message: "Error while fetching result: \(error)", file: #file, line: #line, function: #function)
			case .success(let result):
				self.testResult = result
				self.reloadTestResult(with: result)
			}
		}
	}
}

extension HomeInteractor {
	struct State {
		var isLoading = false
		var summary: ENExposureDetectionSummary?
		var exposureManager: ExposureManagerState
		var numberRiskContacts: Int {
			summary?.numberOfContacts ?? 0
		}

		var daysSinceLastExposure: Int? {
			summary?.daysSinceLastExposure
		}

		var riskLevel: RiskLevel {
			RiskLevel(riskScore: summary?.maximumRiskScore)
		}
	}
}

extension HomeInteractor: StateHandlerObserverDelegate {
	func stateDidChange(to _: RiskDetectionState) {
		updateActiveCell()
	}

	func getLatestExposureManagerState() -> ExposureManagerState {
		state.exposureManager
	}
}

extension HomeInteractor: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		stateHandler.exposureManagerDidUpdate(to: state)
	}
}
