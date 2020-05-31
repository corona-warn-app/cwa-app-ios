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

final class HomeInteractor {
	enum UserLoadingMode {
		case automatic
		case manual
	}

	// MARK: Creating

	init(
		homeViewController: HomeViewController,
		store: Store,
		state: State
	) {
		self.homeViewController = homeViewController
		self.store = store
		self.state = state
		stateHandler = ENStateHandler(self.state.exposureManager, delegate: self)
		cells = initialCellConfigurators()
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
			cells = initialCellConfigurators()
			homeViewController.reloadData()
		}
	}

	private unowned var homeViewController: HomeViewController
	private let store: Store
	var stateHandler: ENStateHandler!

	private var riskLevel: RiskLevel {
		RiskLevel(riskScore: state.summary?.maximumRiskScore)
	}

	private var activeConfigurator: HomeActivateCellConfigurator!
	private var cells: [CollectionViewCellConfiguratorAny] = []
	var cellConfigurators: [CollectionViewCellConfiguratorAny] { cells }
	private var riskConfigurator: HomeRiskCellConfigurator?

	func developerMenuEnableIfAllowed() {}

	private let userLoadingMode = UserLoadingMode.manual // !

	private var isUpdateTaskRunning: Bool = false
	private var updateRiskTimer: Timer?
	private var isTimerRunning: Bool { updateRiskTimer?.isValid ?? false }
	private var releaseDate: Date?
	private var startDate: Date?

	private func riskCellTask(completion: @escaping (() -> Void)) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: completion)
	}

	private func startCheckRisk() {
		let taskScheduler = ENATaskScheduler()

		// TODO: handle state of pending scheduled tasks to determin active state for manual refresh button
		// TODO: disable manual trigger button
		taskScheduler.arePendingTasksScheduled { tasksAreSecheduled in
			if tasksAreSecheduled {
				// TODO: enable manual trigger button
			}
		}

		guard let indexPath = indexPathForRiskCell() else { return }
		riskConfigurator?.startLoading()
		homeViewController.reloadCell(at: indexPath)

		taskScheduler.cancelAllBackgroundTaskRequests()

		riskCellTask(completion: {
			self.riskConfigurator?.stopLoading()
			guard let indexPath = self.indexPathForRiskCell() else { return }
			self.homeViewController.reloadCell(at: indexPath)

			taskScheduler.scheduleBackgroundTaskRequests()
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
		homeViewController.reloadCell(at: indexPath)
	}

	private func startCountdownAndUpdateRisk() {
		startCountdown()
		fetchUpdateRisk()
	}

	private func updateRiskLoading() {
		isUpdateTaskRunning ? riskConfigurator?.startLoading() : riskConfigurator?.stopLoading()
	}

	private func updateRiskCounter() {
		if let releaseDate = releaseDate, isTimerRunning {
			riskConfigurator?.updateCounter(startDate: Date(), releaseDate: releaseDate)
		} else {
			riskConfigurator?.removeCounter()
		}
	}

	private func updateRiskButton() {
		riskConfigurator?.updateButtonEnabled(!isUpdateTaskRunning && !isTimerRunning)
	}

	private func reloadRiskCell() {
		guard let indexPath = indexPathForRiskCell() else { return }
		updateRiskLoading()
		updateRiskButton()
		updateRiskCounter()
		homeViewController.reloadCell(at: indexPath)
	}

	private func initialCellConfigurators() -> [CollectionViewCellConfiguratorAny] {
		let currentState = stateHandler.getState()
		activeConfigurator = HomeActivateCellConfigurator(state: currentState)
		let dateLastExposureDetection = store.dateLastExposureDetection

		let isButtonHidden = userLoadingMode == .automatic
		let isCounterLabelHidden = !isButtonHidden

		if riskLevel != .inactive, userLoadingMode == .automatic {
			startCountdown()
		}

		switch riskLevel {
		case .unknown:
			riskConfigurator = HomeUnknownRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				isButtonHidden: isButtonHidden,
				isCounterLabelHidden: isCounterLabelHidden,
				startDate: startDate,
				releaseDate: releaseDate,
				lastUpdateDate: nil
			)
		case .inactive:
			riskConfigurator = HomeInactiveRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				lastInvestigation: "Geringes Risiko",
				lastUpdateDate: dateLastExposureDetection
			)
		case .low:
			riskConfigurator = HomeLowRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				isButtonHidden: isButtonHidden,
				isCounterLabelHidden: isCounterLabelHidden,
				startDate: startDate,
				releaseDate: releaseDate,
				numberDays: 2,
				totalDays: 14,
				lastUpdateDate: dateLastExposureDetection
			)
		case .high:
			riskConfigurator = HomeHighRiskCellConfigurator(
				isLoading: false,
				isButtonEnabled: true,
				isButtonHidden: isButtonHidden,
				isCounterLabelHidden: isCounterLabelHidden,
				startDate: startDate,
				releaseDate: releaseDate,
				numberRiskContacts: state.numberRiskContacts,
				daysSinceLastExposure: state.daysSinceLastExposure,
				lastUpdateDate: dateLastExposureDetection
			)
		}

		riskConfigurator?.buttonAction = { [unowned self] in
			if self.riskLevel == .inactive {
				// go to settings?
			} else {
				self.startCountdownAndUpdateRisk()
			}
		}

		let submitConfigurator = HomeSubmitCellConfigurator()

		submitConfigurator.submitAction = { [unowned self] in
			self.homeViewController.showSubmitResult()
		}

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

		var configurators: [CollectionViewCellConfiguratorAny] = [activeConfigurator]
		if let risk = riskConfigurator {
			configurators.append(risk)
		}
		let others: [CollectionViewCellConfiguratorAny] = [
			submitConfigurator,
			info1Configurator,
			info2Configurator,
			appInformationConfigurator,
			settingsConfigurator
		]
		configurators.append(contentsOf: others)
		return configurators
	}

	private func indexPathForActiveCell() -> IndexPath? {
		let index = cells.firstIndex { cellConfigurator in
			cellConfigurator === self.activeConfigurator
		}
		guard let item = index else { return nil }
		let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
		return indexPath
	}

	private func indexPathForRiskCell() -> IndexPath? {
		let index = cells.firstIndex { cellConfigurator in
			cellConfigurator === self.riskConfigurator
		}
		guard let item = index else { return nil }
		let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
		return indexPath
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
