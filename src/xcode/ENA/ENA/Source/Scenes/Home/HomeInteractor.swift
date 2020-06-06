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

final class HomeInteractor: RequiresAppDependencies {
	typealias SectionDefinition = (section: HomeViewController.Section, cellConfigurators: [CollectionViewCellConfiguratorAny])
	typealias SectionConfiguration = [SectionDefinition]

	enum UserLoadingMode {
		case automatic
		case manual
	}

	// MARK: Creating

	init(
		homeViewController: HomeViewController,
		state: State,
		exposureSubmissionService: ExposureSubmissionService? = nil,
		initialEnState: ENStateHandler.State
	) {
		self.homeViewController = homeViewController
		self.state = state
		self.enState = initialEnState
		sections = initialCellConfigurators()
		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.state.risk = risk
		}
		riskProvider.observeRisk(riskConsumer)
	}

	// MARK: Properties
	private var enState: ENStateHandler.State
	private let riskConsumer = RiskConsumer()

	var state = HomeInteractor.State(
		isLoading: false,
		exposureManager: .init()
	) {
		didSet {
			homeViewController.setStateOfChildViewControllers(
				.init(
					exposureManager: state.exposureManager
				)
			)
			sections = initialCellConfigurators()
			homeViewController.reloadData()
		}
	}

	private unowned var homeViewController: HomeViewController
	private var exposureSubmissionService: ExposureSubmissionService?
	var enStateHandler: ENStateHandler?

	private var riskLevel: RiskLevel {
		state.riskLevel
	}

	private(set) var sections: SectionConfiguration = []

	private var activeConfigurator: HomeActivateCellConfigurator!
	private var testResultConfigurator = HomeTestResultCellConfigurator()
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
		riskProvider.requestRisk()
	}

	private func startCheckRisk() {
//		riskProvider.requestRisk()
		guard let indexPath = indexPathForRiskCell() else { return }
		riskLevelConfigurator?.startLoading()
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)

		riskCellTask {
			self.riskLevelConfigurator?.stopLoading()
			guard let indexPath = self.indexPathForRiskCell() else { return }
			self.homeViewController.updateSections()
			self.homeViewController.reloadCell(at: indexPath)
		}
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
		testResultConfigurator.testResult = result
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

//		if riskLevel != .inactive, userLoadingMode == .automatic {
//			startCountdown()
//		}

		switch riskLevel {
		case .unknownInitial:
			riskLevelConfigurator = HomeUnknownRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				isButtonHidden: true,
				isCounterLabelHidden: isCounterLabelHidden,
				startDate: startDate,
				releaseDate: releaseDate,
				lastUpdateDate: nil
			)
		case .inactive:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(incativeType: .noCalculationPossible, lastInvestigation: "Geringes Risiko", lastUpdateDate: dateLastExposureDetection)
		case .unknownOutdated:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(incativeType: .outdatedResults, lastInvestigation: "Geringes Risiko", lastUpdateDate: dateLastExposureDetection)
		case .low:
			riskLevelConfigurator = HomeLowRiskCellConfigurator(
				startDate: startDate,
				releaseDate: releaseDate,
				numberRiskContacts: state.numberRiskContacts,
				numberDays: 2,
				totalDays: 14,
				lastUpdateDate: dateLastExposureDetection
			)
			riskLevelConfigurator?.isButtonHidden = true // TODO: hide isButtonHidden
			riskLevelConfigurator?.isCounterLabelHidden = isCounterLabelHidden
		case .increased:
			riskLevelConfigurator = HomeHighRiskCellConfigurator(
				startDate: startDate,
				releaseDate: releaseDate,
				numberRiskContacts: state.numberRiskContacts,
				daysSinceLastExposure: state.daysSinceLastExposure,
				lastUpdateDate: dateLastExposureDetection
			)
			riskLevelConfigurator?.isButtonHidden = true // TODO: isButtonHidden
			riskLevelConfigurator?.isCounterLabelHidden = isCounterLabelHidden
		}
		riskLevelConfigurator?.buttonAction = { [unowned self] in
			self.startCountdownAndUpdateRisk()
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

	private func setupTestResultConfigurator() -> HomeTestResultCellConfigurator {
		testResultConfigurator.buttonAction = homeViewController.showTestResultScreen
		return testResultConfigurator
	}

	func setupSubmitConfigurator() -> HomeSubmitCellConfigurator {
		let submitConfigurator = HomeSubmitCellConfigurator()
		submitConfigurator.submitAction = homeViewController.showExposureSubmissionWithoutResult
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
		return HomeActivateCellConfigurator(state: enState)
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
			appLogger.log(message: "Reached end of life state.", file: #file, line: #line, function: #function)

		} else if store.registrationToken != nil {
			// This is shown when we registered a test.
			// Note that the `positive` state has a custom cell and the risk cell will not be shown once the user was tested positive.

			switch testResult {
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
		guard store.registrationToken != nil else { return }

		self.exposureSubmissionService?.getTestResult { [weak self] result in
			switch result {
			case .failure:
				self?.testResult = nil
			case .success(let result):
				self?.testResult = result
				self?.reloadTestResult(with: result)
			}
		}
	}
}

extension HomeInteractor {
	struct State {
		var isLoading = false
		var exposureManager: ExposureManagerState
		var numberRiskContacts: Int {
			risk?.details.numberOfExposures ?? 0
		}

		var daysSinceLastExposure: Int? {
			guard let date = risk?.details.exposureDetectionDate else {
				return nil
			}
			return Calendar.current.dateComponents([.day], from: date, to: Date()).day
		}

		var risk: Risk?
		var riskLevel: RiskLevel { risk?.level ?? .unknownInitial }
	}
}

// MARK: The ENStateHandler updating
extension HomeInteractor: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
		activeConfigurator.updateEnState(state)
		updateActiveCell()
	}
}
