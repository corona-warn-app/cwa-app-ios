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

	// MARK: Creating

	init(
		homeViewController: HomeViewController,
		state: State,
		exposureSubmissionService: ExposureSubmissionService? = nil,
		initialEnState: ENStateHandler.State
	) {
		self.homeViewController = homeViewController
		self.state = state
		self.exposureSubmissionService = exposureSubmissionService
		self.enState = initialEnState
		sections = initialCellConfigurators()
		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.state.risk = risk
			self?.homeViewController.state.risk = risk
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
					exposureManagerState: state.exposureManager,
					detectionMode: state.detectionMode
				)
			)
			sections = initialCellConfigurators()
			homeViewController.reloadData()
		}
	}

	private unowned var homeViewController: HomeViewController
	private var exposureSubmissionService: ExposureSubmissionService?
	var enStateHandler: ENStateHandler?

	private var riskLevel: RiskLevel { state.riskLevel }
	private var detectionMode: DetectionMode { state.detectionMode }
	private(set) var sections: SectionConfiguration = []

	private var activeConfigurator: HomeActivateCellConfigurator!
	private var testResultConfigurator = HomeTestResultCellConfigurator()
	private var riskLevelConfigurator: HomeRiskLevelCellConfigurator?
	private var inactiveConfigurator: HomeInactiveRiskCellConfigurator?

	private var isUpdateTaskRunning: Bool = false
	private(set) var testResult: TestResult?

	func updateActiveCell() {
		guard let indexPath = indexPathForActiveCell() else { return }
		homeViewController.updateSections()
		homeViewController.reloadCell(at: indexPath)
	}

	private func updateRiskLoading() {
		isUpdateTaskRunning ? riskLevelConfigurator?.startLoading() : riskLevelConfigurator?.stopLoading()
	}

	private func updateRiskButton() {
		riskLevelConfigurator?.updateButtonEnabled(!isUpdateTaskRunning)
	}

	private func reloadRiskCell() {
		guard let indexPath = indexPathForRiskCell() else { return }
		updateRiskLoading()
		updateRiskButton()
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
		sections[0] = setupActionSectionDefinition()
		homeViewController.updateSections()
		homeViewController.applySnapshotFromSections(animatingDifferences: true)
		homeViewController.reloadData()
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

		switch riskLevel {
		case .unknownInitial:
			riskLevelConfigurator = HomeUnknownRiskCellConfigurator(
				isLoading: false,
				detectionIntervalLabelHidden: false,
				lastUpdateDate: nil,
				detectionInterval: detectionInterval,
				detectionMode: detectionMode,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState
			)
		case .inactive:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				incativeType: .noCalculationPossible,
				lastInvestigation: "Geringes Risiko",
				lastUpdateDate: dateLastExposureDetection
			)
		case .unknownOutdated:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				incativeType: .outdatedResults,
				lastInvestigation: "Geringes Risiko",
				lastUpdateDate: dateLastExposureDetection
			)
		case .low:
			riskLevelConfigurator = HomeLowRiskCellConfigurator(
				numberRiskContacts: state.numberRiskContacts,
				numberDays: state.risk?.details.numberOfDaysWithActiveTracing ?? 0,
				totalDays: 14,
				lastUpdateDate: dateLastExposureDetection,
				isButtonHidden: detectionIsAutomatic,
				detectionMode: detectionMode,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionInterval: detectionInterval
			)
		case .increased:
			riskLevelConfigurator = HomeHighRiskCellConfigurator(
				numberRiskContacts: state.numberRiskContacts,
				daysSinceLastExposure: state.daysSinceLastExposure,
				lastUpdateDate: dateLastExposureDetection,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState,
				detectionMode: detectionMode,
				validityDuration: detectionInterval
			)
		}
		riskLevelConfigurator?.buttonAction = {
			self.riskProvider.requestRisk(userInitiated: true)
		}
		return riskLevelConfigurator ?? inactiveConfigurator
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
		guard store.registrationToken != nil else { return }

		// Make sure to make the loading cell appear for at least `minRequestTime`.
		// This avoids an ugly flickering when the cell is only shown for the fraction of a second.
		// Make sure to only trigger this additional delay when no other test result is present already.
		let requestStart = Date()
		let minRequestTime: TimeInterval = 2.0

		self.exposureSubmissionService?.getTestResult { [weak self] result in
			switch result {
			case .failure:
				// TODO: initiate retry?
				self?.testResult = nil
			case .success(let result):
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

extension HomeInteractor {
	struct State {
		var detectionMode = DetectionMode.default
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
