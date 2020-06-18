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
import UIKit

protocol HomeViewControllerDelegate: AnyObject {
	func homeViewControllerUserDidRequestReset(_ controller: HomeViewController)
}

extension HomeViewController: RequiresAppDependencies {}

// swiftlint:disable:next type_body_length
final class HomeViewController: UIViewController {
	// MARK: Creating a Home View Controller
	init?(
		coder: NSCoder,
		delegate: HomeViewControllerDelegate,
		detectionMode: DetectionMode,
		exposureManagerState: ExposureManagerState,
		initialEnState: ENStateHandler.State,
		risk: Risk?
	) {
		self.delegate = delegate
		super.init(coder: coder)
		sections = initialCellConfigurators()
		navigationItem.largeTitleDisplayMode = .never
	}


	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	deinit {
		enStateUpdatingSet.removeAllObjects()
	}

	// MARK: Properties
	private(set) var isRequestRiskRunning = false
	private var sections: SectionConfiguration = []
	private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
	private var collectionView: UICollectionView! { view as? UICollectionView }
	private var activeConfigurator: HomeActivateCellConfigurator!
	private var testResultConfigurator = HomeTestResultCellConfigurator()
	private var riskLevelConfigurator: HomeRiskLevelCellConfigurator?
	private var inactiveConfigurator: HomeInactiveRiskCellConfigurator?
	private(set) var testResult: TestResult?
	private weak var exposureDetectionController: ExposureDetectionViewController?
	private weak var settingsController: SettingsViewController?
	private weak var notificationSettingsController: ExposureNotificationSettingViewController?
	private weak var delegate: HomeViewControllerDelegate?
	lazy var exposureSubmissionService: ExposureSubmissionService = {
		ENAExposureSubmissionService(
			diagnosiskeyRetrieval: self.exposureManager,
			client: self.client,
			store: self.store
		)
	}()
	var enStateHandler: ENStateHandler?
	private var enStateUpdatingSet = NSHashTable<AnyObject>.weakObjects()
	private var state = State(
		detectionMode: .default,
		exposureManagerState: .init(),
		enState: .unknown,
		risk: nil
		) {
		didSet {
			print("🎃 Update")
			exposureDetectionController?.state = ExposureDetectionViewController.State(
				exposureManagerState: state.exposureManagerState,
				detectionMode: state.detectionMode,
				isLoading: isRequestRiskRunning,
				risk: state.risk
			)
			sections = initialCellConfigurators()
			reloadData()
		}
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		configureCollectionView()
		configureDataSource()
		updateSections()
		applySnapshotFromSections()
		setupAccessibility()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateTestResults()
		requestRisk(userInitiated: false)
		updateBackgroundColor()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBackgroundColor()
	}

	private func setupAccessibility() {
		navigationItem.leftBarButtonItem?.customView = UIImageView(image: navigationItem.leftBarButtonItem?.image)
		navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		navigationItem.leftBarButtonItem?.accessibilityTraits = .none
		navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = "AppStrings.Home.leftBarButtonDescription"
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppStrings.Home.rightBarButtonDescription"
	}

	// MARK: Actions

	@IBAction private func infoButtonTapped() {
		present(
			AppStoryboard.riskLegend.initiateInitial(),
			animated: true,
			completion: nil
		)
	}

	// MARK: Misc

	// Called by SceneDelegate
	func updateState(
		detectionMode: DetectionMode,
		exposureManagerState: ExposureManagerState,
		risk: Risk?
	) {
		var newState = state

		newState.detectionMode = detectionMode
		newState.exposureManagerState = exposureManagerState
		newState.risk = risk

		state = newState
	}

	func showExposureSubmissionWithoutResult() {
		showExposureSubmission()
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		present(
			AppStoryboard.exposureSubmission.initiateInitial { coder in
				ExposureSubmissionNavigationController(
					coder: coder,
					exposureSubmissionService: self.exposureSubmissionService,
					submissionDelegate: self,
					testResult: result
				)
			},
			animated: true
		)
	}

	func showDeveloperMenu() {
		present(
			AppStoryboard.developerMenu.initiateInitial(),
			animated: true,
			completion: nil
		)
	}

	func showInviteFriends() {
		navigationController?.pushViewController(
			FriendsInviteController.initiate(for: .inviteFriends),
			animated: true
		)
	}

	func showExposureNotificationSetting() {
		let storyboard = AppStoryboard.exposureNotificationSetting.instance
		let vc = storyboard.instantiateViewController(identifier: "ExposureNotificationSettingViewController") { coder in
			ExposureNotificationSettingViewController(
					coder: coder,
					initialEnState: self.state.enState,
					store: self.store,
					delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
		notificationSettingsController = vc
		navigationController?.pushViewController(vc, animated: true)
	}

	func showSetting() {
		let storyboard = AppStoryboard.settings.instance
		let vc = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
			SettingsViewController(
				coder: coder,
				store: self.store,
				initialEnState: self.state.enState,
				delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
		settingsController = vc
		navigationController?.pushViewController(vc, animated: true)
	}

	func showExposureDetection() {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: self.state.exposureManagerState,
			detectionMode: self.state.detectionMode,
			isLoading: isRequestRiskRunning,
			risk: self.state.risk
		)
		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				delegate: self
			)
		}
//		addToUpdatingSetIfNeeded(vc)
		exposureDetectionController = vc as? ExposureDetectionViewController
		present(vc, animated: true)
	}

	func showAppInformation() {
		navigationController?.pushViewController(
			AppInformationViewController(),
			animated: true
		)
	}

	private func showScreenForActionSectionForCell(at indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		switch cell {
		case is ActivateCollectionViewCell:
			showExposureNotificationSetting()
		case is RiskLevelCollectionViewCell:
		 	showExposureDetection()
		case is RiskFindingPositiveCollectionViewCell:
			showExposureSubmission(with: testResult)
		case is HomeTestResultCollectionViewCell:
			showExposureSubmission(with: testResult)
		case is RiskInactiveCollectionViewCell:
			showExposureDetection()
		case is RiskThankYouCollectionViewCell:
			return
		default:
			log(message: "Unknown cell type tapped.", file: #file, line: #line, function: #function)
			return
		}
	}

	private func showScreen(at indexPath: IndexPath) {
		guard let section = Section(rawValue: indexPath.section) else { return }
		let row = indexPath.row
		switch section {
		case .actions:
			showScreenForActionSectionForCell(at: indexPath)
		case .infos:
			if row == 0 {
				showInviteFriends()
			} else {
				WebPageHelper.showWebPage(from: self)
			}
		case .settings:
			if row == 0 {
				showAppInformation()
			} else {
				showSetting()
			}
		}
	}

	// MARK: Configuration

	func reloadData() {
		guard isViewLoaded else { return }
		updateSections()
		collectionView.reloadData()
	}

	func reloadCell(at indexPath: IndexPath) {
		guard let snapshot = dataSource?.snapshot() else { return }
		guard let cell = collectionView.cellForItem(at: indexPath) else { return }
		sections[indexPath.section].cellConfigurators[indexPath.item].configureAny(cell: cell)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}

	private func configureCollectionView() {
		collectionView.collectionViewLayout = .homeLayout(delegate: self)
		collectionView.delegate = self

		collectionView.contentInset = UIEdgeInsets(top: UICollectionViewLayout.topInset, left: 0, bottom: -UICollectionViewLayout.bottomBackgroundOverflowHeight, right: 0)

		collectionView.isAccessibilityElement = false
		collectionView.shouldGroupAccessibilityChildren = true

		let cellTypes: [UICollectionViewCell.Type] = [
			ActivateCollectionViewCell.self,
			RiskLevelCollectionViewCell.self,
			InfoCollectionViewCell.self,
			HomeTestResultCollectionViewCell.self,
			RiskInactiveCollectionViewCell.self,
			RiskFindingPositiveCollectionViewCell.self,
			RiskThankYouCollectionViewCell.self,
			InfoCollectionViewCell.self,
			HomeTestResultLoadingCell.self
		]

		collectionView.register(cellTypes: cellTypes)
	}

	private func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { [unowned self] collectionView, indexPath, _ in
			let configurator = self.sections[indexPath.section].cellConfigurators[indexPath.row]
			let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
			cell.unhighlight()
			configurator.configureAny(cell: cell)
			return cell
		}
	}

	func applySnapshotFromSections(animatingDifferences: Bool = false) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems( section.cellConfigurators.map { $0.identifier })
		}
		dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
	}

	func updateSections() {
//		sections = homeInteractor.sections
	}

	private func updateBackgroundColor() {
		if traitCollection.userInterfaceStyle == .light {
			collectionView.backgroundColor = .enaColor(for: .background)
		} else {
			collectionView.backgroundColor = .enaColor(for: .separator)
		}
	}
}

// MARK: - Update test state.

extension HomeViewController {
	func showTestResultScreen() {
		showExposureSubmission(with: testResult)
	}

	func updateTestResultState() {
		reloadActionSection()
		updateTestResults()
	}
}

extension HomeViewController: HomeLayoutDelegate {
	func homeLayoutSection(for sectionIndex: Int) -> Section? {
		Section(rawValue: sectionIndex)
	}
}

extension HomeViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		let cell = collectionView.cellForItem(at: indexPath)
		switch cell {
		case is RiskThankYouCollectionViewCell: return false
		default: return true
		}
	}

	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.highlight()
	}

	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.unhighlight()
	}

	func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showScreen(at: indexPath)
	}
}

extension HomeViewController: ExposureDetectionViewControllerDelegate {
	func didStartLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		updateAndReloadRiskLoading(isRequestRiskRunning: true)
	}

	func didFinishLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		updateAndReloadRiskLoading(isRequestRiskRunning: false)
	}

	func exposureDetectionViewController(
		_: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension HomeViewController: ExposureNotificationSettingViewControllerDelegate {
	func exposureNotificationSettingViewController(
		_: ExposureNotificationSettingViewController,
		setExposureManagerEnabled enabled: Bool,
		then completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

extension HomeViewController: SettingsViewControllerDelegate {
	func settingsViewControllerUserDidRequestReset(_: SettingsViewController) {
		delegate?.homeViewControllerUserDidRequestReset(self)
	}

	func settingsViewController(
		_: SettingsViewController,
		setExposureManagerEnabled enabled: Bool,
		then completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

private extension HomeViewController {
	func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			exposureManager.enable(completion: completion)
		} else {
			exposureManager.disable(completion: completion)
		}
	}
}

extension HomeViewController: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		self.state.exposureManagerState = state
		updateOwnUI()
		exposureDetectionController?.updateUI()
		settingsController?.updateExposureState(state)
	}

	private func updateOwnUI() {
		reloadData()
	}
}


extension HomeViewController: NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (collectionView.adjustedContentInset.top + collectionView.contentOffset.y) / collectionView.contentInset.top
		return max(0, min(alpha, 1))
	}
}

extension HomeViewController: ExposureSubmissionNavigationControllerDelegate {
	func exposureSubmissionNavigationControllerWillDisappear(_ controller: ExposureSubmissionNavigationController) {
		updateTestResultState()
	}
}

private extension UICollectionViewCell {
	func highlight() {
		let highlightView = UIView(frame: bounds)
		highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		highlightView.backgroundColor = .enaColor(for: .listHighlight)
		highlightView.tag = 100_000
		highlightView.clipsToBounds = true

		if let homeCollectionViewCell = self as? HomeCardCollectionViewCell {
			highlightView.layer.cornerRadius = homeCollectionViewCell.contentView.layer.cornerRadius
		}
		addSubview(highlightView)
	}

	func unhighlight() {
		subviews.filter(({ $0.tag == 100_000 })).forEach({ $0.removeFromSuperview() })
	}
}



extension HomeViewController {
	typealias SectionDefinition = (section: HomeViewController.Section, cellConfigurators: [CollectionViewCellConfiguratorAny])
	typealias SectionConfiguration = [SectionDefinition]

	// MARK: Creating

	//	init(
	//		homeViewController: HomeViewController,
	//		state: State
	//	) {
	//		self.homeViewController = homeViewController
	//		self.state = state
	//		sections = initialCellConfigurators()
	//	}

	// MARK: Properties
	private var riskLevel: RiskLevel { state.riskLevel }
	private var detectionMode: DetectionMode { state.detectionMode }

	private func updateActiveCell() {
		guard let indexPath = indexPathForActiveCell() else { return }
		updateSections()
		reloadCell(at: indexPath)
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
		updateSections()
		reloadCell(at: indexPath)
	}


	func updateAndReloadRiskLoading(isRequestRiskRunning: Bool) {
		self.isRequestRiskRunning = isRequestRiskRunning
		updateRiskLoading()
		reloadRiskCell()
	}

	func requestRisk(userInitiated: Bool) {

		if userInitiated {
			updateAndReloadRiskLoading(isRequestRiskRunning: true)
			riskProvider.requestRisk(userInitiated: userInitiated) { _ in
				self.updateAndReloadRiskLoading(isRequestRiskRunning: false)
			}
		} else {
			riskProvider.requestRisk(userInitiated: userInitiated)
		}

	}

	private func initialCellConfigurators() -> SectionConfiguration {
		let info1Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardShareTitle,
			description: AppStrings.Home.infoCardShareBody,
			position: .first,
			accessibilityIdentifier: "AppStrings.Home.infoCardShareTitle"
		)

		let info2Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardAboutTitle,
			description: AppStrings.Home.infoCardAboutBody,
			position: .last,
			accessibilityIdentifier: "AppStrings.Home.infoCardAboutTitle"
		)

		let appInformationConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.appInformationCardTitle,
			description: nil,
			position: .first,
			accessibilityIdentifier: "AppStrings.Home.appInformationCardTitle"
		)

		let settingsConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.settingsCardTitle,
			description: nil,
			position: .last,
			accessibilityIdentifier: "AppStrings.Home.settingsCardTitle"
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

extension HomeViewController {

	private func reloadTestResult(with result: TestResult) {
		testResultConfigurator.testResult = result
		reloadActionSection()
		guard let indexPath = indexPathForTestResultCell() else { return }
		reloadCell(at: indexPath)
	}

	func reloadActionSection() {
		sections[0] = setupActionSectionDefinition()
		updateSections()
		applySnapshotFromSections(animatingDifferences: true)
		reloadData()
	}
}

// MARK: - Action section setup helpers.

extension HomeViewController {
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
				lastUpdateDate: nil,
				detectionInterval: detectionInterval,
				detectionMode: detectionMode,
				manualExposureDetectionState: riskProvider.manualExposureDetectionState
			)
		case .inactive:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				incativeType: .noCalculationPossible,
				previousRiskLevel: store.previousRiskLevel,
				lastUpdateDate: dateLastExposureDetection
			)
			inactiveConfigurator?.activeAction = inActiveCellActionHandler

		case .unknownOutdated:
			inactiveConfigurator = HomeInactiveRiskCellConfigurator(
				incativeType: .outdatedResults,
				previousRiskLevel: store.previousRiskLevel,
				lastUpdateDate: dateLastExposureDetection
			)
			inactiveConfigurator?.activeAction = inActiveCellActionHandler

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
			self.requestRisk(userInitiated: true)
		}
		return riskLevelConfigurator ?? inactiveConfigurator
	}

	private func setupTestResultConfigurator() -> HomeTestResultCellConfigurator {
		testResultConfigurator.primaryAction = showTestResultScreen
		return testResultConfigurator
	}

	func setupSubmitConfigurator() -> HomeTestResultCellConfigurator {
		let submitConfigurator = HomeTestResultCellConfigurator()
		submitConfigurator.primaryAction = { self.showExposureSubmission(with: nil) }
		return submitConfigurator
	}

	func setupFindingPositiveRiskCellConfigurator() -> HomeFindingPositiveRiskCellConfigurator {
		let configurator = HomeFindingPositiveRiskCellConfigurator()
		configurator.nextAction = {
			self.showExposureSubmission(with: self.testResult)
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

extension HomeViewController {

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

extension HomeViewController {
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
				self?.alertError(
					message: error.localizedDescription,
					title: AppStrings.Home.resultCardLoadingErrorTitle,
					completion: {
						self?.testResult = .pending
						self?.reloadTestResult(with: .pending)
					}
				)

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

// MARK: The ENStateHandler updating
//extension HomeViewController: ENStateHandlerUpdating {
//	func updateEnState(_ state: ENStateHandler.State) {
//	}
//}


extension HomeViewController: ENStateHandlerUpdating {
	func updateEnState(_ newState: ENStateHandler.State) {
		state.enState = newState
		self.state.enState = newState
		activeConfigurator.updateEnState(newState)
		updateActiveCell()
		updateAllState(newState)
	}

	private func updateAllState(_ state: ENStateHandler.State) {
		enStateUpdatingSet.allObjects.forEach { anyObject in
			if let updating = anyObject as? ENStateHandlerUpdating {
				updating.updateEnState(state)
			}
		}
	}

	private func addToUpdatingSetIfNeeded(_ anyObject: AnyObject?) {
		if let anyObject = anyObject,
			anyObject is ENStateHandlerUpdating {
			enStateUpdatingSet.add(anyObject)
		}
	}
}

extension HomeViewController {
	private func inActiveCellActionHandler() {
		showExposureNotificationSetting()
	}
}
