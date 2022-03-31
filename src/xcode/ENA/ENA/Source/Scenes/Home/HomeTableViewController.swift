////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

// swiftlint:disable:next type_body_length
class HomeTableViewController: UITableViewController, NavigationBarOpacityDelegate {

	// MARK: - Init

	init(
		viewModel: HomeTableViewModel,
		appConfigurationProvider: AppConfigurationProviding,
		route: Route?,
		startupErrors: [Error],
		onInfoBarButtonItemTap: @escaping () -> Void,
		onExposureLoggingCellTap: @escaping (ENStateHandler.State) -> Void,
		onRiskCellTap: @escaping (HomeState) -> Void,
		onFamilyTestResultsCellTap: @escaping () -> Void,
		onInactiveCellButtonTap: @escaping (ENStateHandler.State) -> Void,
		onTestRegistrationCellTap: @escaping () -> Void,
		onStatisticsInfoButtonTap: @escaping () -> Void,
		onTraceLocationsCellTap: @escaping () -> Void,
		onInviteFriendsCellTap: @escaping () -> Void,
		onFAQCellTap: @escaping () -> Void,
		onSocialMediaCellTap: @escaping () -> Void,
		onAppInformationCellTap: @escaping () -> Void,
		onSettingsCellTap: @escaping (ENStateHandler.State) -> Void,
		onRecycleBinCellTap: @escaping () -> Void,
		showTestInformationResult: @escaping (Result<CoronaTestRegistrationInformation, QRCodeError>) -> Void,
		onAddLocalStatisticsTap: @escaping (SelectValueTableViewController) -> Void,
		onAddDistrict: @escaping (SelectValueTableViewController) -> Void,
		onDismissState: @escaping () -> Void,
		onDismissDistrict: @escaping (Bool) -> Void
	) {
		self.viewModel = viewModel
		self.appConfigurationProvider = appConfigurationProvider
		self.route = route
		self.startupErrors = startupErrors
		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onExposureLoggingCellTap = onExposureLoggingCellTap
		self.onRiskCellTap = onRiskCellTap
		self.onFamilyTestResultsCellTap = onFamilyTestResultsCellTap
		self.onInactiveCellButtonTap = onInactiveCellButtonTap
		self.onTestRegistrationCellTap = onTestRegistrationCellTap
		self.onStatisticsInfoButtonTap = onStatisticsInfoButtonTap
		self.onTraceLocationsCellTap = onTraceLocationsCellTap
		self.onInviteFriendsCellTap = onInviteFriendsCellTap
		self.onFAQCellTap = onFAQCellTap
		self.onSocialMediaCellTap = onSocialMediaCellTap
		self.onAppInformationCellTap = onAppInformationCellTap
		self.onSettingsCellTap = onSettingsCellTap
		self.onRecycleBinCellTap = onRecycleBinCellTap
		self.showTestInformationResult = showTestInformationResult
		self.onAddStateButtonTap = onAddLocalStatisticsTap
		self.onAddDistrict = onAddDistrict
		self.onDismissState = onDismissState
		self.onDismissDistrict = onDismissDistrict

		super.init(style: .grouped)

		viewModel.$riskAndTestResultsRows
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] _ in
				self?.tableView.reloadSections([HomeTableViewModel.Section.riskAndTestResults.rawValue], with: .none)
				self?.viewModel.isUpdating = false
			}
			.store(in: &subscriptions)

		viewModel.$testResultLoadingError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] error in
				guard let self = self, let error = error else { return }

				self.viewModel.testResultLoadingError = nil

				self.alertError(
					message: error.localizedDescription,
					title: AppStrings.Home.TestResult.resultCardLoadingErrorTitle
				)
			}
			.store(in: &subscriptions)

		viewModel.state.$statisticsLoadingError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] statisticsLoadingError in
				guard let self = self, statisticsLoadingError != nil else { return }

				self.viewModel.state.statisticsLoadingError = nil

				self.alertError(
					message: AppStrings.Statistics.error,
					title: nil
				)
			}
			.store(in: &subscriptions)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBarButtonItems()
		setupTableView()

		navigationItem.largeTitleDisplayMode = .automatic
		tableView.backgroundColor = .enaColor(for: .darkBackground)

		NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterResumingFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: NSNotification.Name.NSCalendarDayChanged, object: nil)

		refreshUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		/// preload expensive and updating cells to increase initial scrolling performance (especially of the statistics cell) and prevent animation on initial appearance
		if statisticsCell == nil {
			riskCell = riskCell(forRowAt: IndexPath(row: 0, section: HomeTableViewModel.Section.riskAndTestResults.rawValue))
			pcrTestResultCell = testResultCell(forRowAt: IndexPath(row: 1, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .pcr)
			pcrTestShownPositiveResultCell = shownPositiveTestResultCell(forRowAt: IndexPath(row: 1, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .pcr)
			antigenTestResultCell = testResultCell(forRowAt: IndexPath(row: 2, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .antigen)
			antigenTestShownPositiveResultCell = shownPositiveTestResultCell(forRowAt: IndexPath(row: 2, section: HomeTableViewModel.Section.riskAndTestResults.rawValue), coronaTestType: .antigen)
			statisticsCell = statisticsCell(forRowAt: IndexPath(row: 0, section: HomeTableViewModel.Section.statistics.rawValue))
			familyTestCell = familyTestCellFactory()
		}

		/** navigationbar is a shared property - so we need to trigger a resizing because others could have set it to true*/
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.sizeToFit()

		viewModel.state.requestRisk(userInitiated: false)
		viewModel.resetBadgeCount()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		#if DEBUG
		if isUITesting && LaunchArguments.test.common.showTestResultCards.boolValue {
			tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .top, animated: false)
		}
		#endif
		
		showDeltaOnboardingAndAlertsIfNeeded()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	// swiftlint:disable:next cyclomatic_complexity
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			return exposureLoggingCell(forRowAt: indexPath)
		case .riskAndTestResults:
			switch viewModel.riskAndTestResultsRows[indexPath.row] {
			case .risk:
				return riskCell(forRowAt: indexPath)
			case .pcrTestResult(let testState):
				switch testState {
				case .default:
					return testResultCell(forRowAt: indexPath, coronaTestType: .pcr)
				case .positiveResultWasShown:
					return shownPositiveTestResultCell(forRowAt: indexPath, coronaTestType: .pcr)
				}

			case .antigenTestResult(let testState):
				switch testState {
				case .default:
					return testResultCell(forRowAt: indexPath, coronaTestType: .antigen)
				case .positiveResultWasShown:
					return shownPositiveTestResultCell(forRowAt: indexPath, coronaTestType: .antigen)
				}
			case .familyTestResults:
				return familyTestCellFactory()
			}
		case .testRegistration:
			return testRegistrationCell(forRowAt: indexPath)
		case .statistics:
			return statisticsCell(forRowAt: indexPath)
		case .traceLocations:
			return traceLocationsCell(forRowAt: indexPath)
		case .moreInfo:
			return moreInfoCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()

		return headerView
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let headerView = UIView()

		return headerView
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return viewModel.heightForRow(at: indexPath)
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			onExposureLoggingCellTap(viewModel.state.enState)
		case .riskAndTestResults:
			switch viewModel.riskAndTestResultsRows[indexPath.row] {
			case .risk:
				onRiskCellTap(viewModel.state)
			case .pcrTestResult:
				viewModel.didTapTestResultCell(coronaTestType: .pcr)
			case .antigenTestResult:
				viewModel.didTapTestResultCell(coronaTestType: .antigen)
			case .familyTestResults:
				onFamilyTestResultsCellTap()
			}
		case .testRegistration:
			onTestRegistrationCellTap()
		case .traceLocations:
			onTraceLocationsCellTap()
		case .statistics, .moreInfo:
			break
		default:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol NavigationBarOpacityDelegate

	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (tableView.adjustedContentInset.top + tableView.contentOffset.y) / 32
		return max(0, min(alpha, 1))
	}

	// MARK: - Internal

	var route: Route?
	var startupErrors: [Error]

	func scrollToTop(animated: Bool) {
		tableView.setContentOffset(.zero, animated: animated)
	}

	func showDeltaOnboardingAndAlertsIfNeeded() {
		guard !deltaOnboardingIsRunning else {
			Log.debug("Skip onboarding and alerts, because the process is already in progress.", log: .onboarding)
			return
		}
		self.deltaOnboardingIsRunning = true

		self.showStartupErrorsIfNeeded {
			self.showDeltaOnboardingIfNeeded(completion: { [weak self] in
				self?.showInformationHowRiskDetectionWorksIfNeeded(completion: {
					self?.showBackgroundFetchAlertIfNeeded(completion: {
						self?.showAnotherHighExposureAlertIfNeeded(completion: {
							self?.showRiskStatusLoweredAlertIfNeeded(completion: {
								self?.showQRScannerTooltipIfNeeded(completion: {  [weak self] in
									self?.showRouteIfNeeded(completion: { [weak self] in
										self?.deltaOnboardingIsRunning = false
									})
								})
							})
						})
					})
				})
			})
		}
	}

	// MARK: - Private

	private let viewModel: HomeTableViewModel
	private let appConfigurationProvider: AppConfigurationProviding

	private let onInfoBarButtonItemTap: () -> Void
	private let onExposureLoggingCellTap: (ENStateHandler.State) -> Void
	private let onRiskCellTap: (HomeState) -> Void
	private let onFamilyTestResultsCellTap: () -> Void
	private let onInactiveCellButtonTap: (ENStateHandler.State) -> Void
	private let onTestRegistrationCellTap: () -> Void
	private let onStatisticsInfoButtonTap: () -> Void
	private let onTraceLocationsCellTap: () -> Void
	private let onInviteFriendsCellTap: () -> Void
	private let onFAQCellTap: () -> Void
	private let onAppInformationCellTap: () -> Void
	private let onSocialMediaCellTap: () -> Void
	private let onSettingsCellTap: (ENStateHandler.State) -> Void
	private let onRecycleBinCellTap: () -> Void
	private let showTestInformationResult: (Result<CoronaTestRegistrationInformation, QRCodeError>) -> Void
	private var onAddStateButtonTap: (SelectValueTableViewController) -> Void
	private var onAddDistrict: (SelectValueTableViewController) -> Void
	private var onDismissState: () -> Void
	private var onDismissDistrict: (Bool) -> Void

	private var deltaOnboardingCoordinator: DeltaOnboardingCoordinator?
	private var deltaOnboardingIsRunning = false
	private var riskCell: UITableViewCell?
	private var pcrTestResultCell: UITableViewCell?
	private var pcrTestShownPositiveResultCell: UITableViewCell?
	private var antigenTestResultCell: UITableViewCell?
	private var antigenTestShownPositiveResultCell: UITableViewCell?
	private var statisticsCell: HomeStatisticsTableViewCell?
	private var familyTestCell: FamilyTestsHomeCell?

	private var subscriptions = Set<AnyCancellable>()

	private func setupBarButtonItems() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Corona-Warn-App"), style: .plain, target: nil, action: nil)
		navigationItem.leftBarButtonItem?.customView = UIImageView(image: navigationItem.leftBarButtonItem?.image)
		navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		navigationItem.leftBarButtonItem?.accessibilityTraits = .none
		navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription

		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}

	private func setupTableView() {
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.Home.tableView
		
		tableView.register(
			UINib(nibName: String(describing: HomeExposureLoggingTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeExposureLoggingTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeRiskTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeRiskTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTestResultTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTestResultTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeShownPositiveTestResultTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeShownPositiveTestResultTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTestRegistrationTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTestRegistrationTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeStatisticsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeStatisticsTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeTraceLocationsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeTraceLocationsTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeMoreInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeMoreInfoTableViewCell.self)
		)

		tableView.register(FamilyTestsHomeCell.self, forCellReuseIdentifier: FamilyTestsHomeCell.reuseIdentifier)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		/// Overestimate to fix auto layout warnings and fix a problem that showed the test cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}

	private func animateChanges(of cell: UITableViewCell) {
		/// DispatchQueue prevents undefined behaviour in `visibleCells` while cells are being updated
		/// https://developer.apple.com/forums/thread/117537
		DispatchQueue.main.async { [self] in
			guard !viewModel.isUpdating, tableView.visibleCells.contains(cell) else {
				return
			}
			
			/// Animate the changed cell height
			tableView.performBatchUpdates(nil, completion: nil)

			/// Keep the other visible cells maskToBounds off during the animation to avoid flickering shadows due to them being cut off (https://stackoverflow.com/a/59581645)
			for cell in tableView.visibleCells {
				cell.layer.masksToBounds = false
				cell.contentView.layer.masksToBounds = false
			}
		}
	}

	private func exposureLoggingCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeExposureLoggingTableViewCell.self), for: indexPath) as? HomeExposureLoggingTableViewCell else {
			fatalError("Could not dequeue HomeExposureLoggingTableViewCell")
		}

		cell.configure(with: HomeExposureLoggingCellModel(state: viewModel.state))

		return cell
	}

	private func riskCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		if let riskCell = riskCell {
			return riskCell
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeRiskTableViewCell.self), for: indexPath) as? HomeRiskTableViewCell else {
			fatalError("Could not dequeue HomeRiskTableViewCell")
		}

		let cellModel = HomeRiskCellModel(
			homeState: viewModel.state,
			onInactiveButtonTap: { [weak self] in
				guard let self = self else { return }

				self.onInactiveCellButtonTap(self.viewModel.state.enState)
			},
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(with: cellModel)

		riskCell = cell

		return cell
	}

	private func familyTestCellFactory() -> FamilyTestsHomeCell {
		if let familyTestCell = familyTestCell {
			return familyTestCell
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: FamilyTestsHomeCell.reuseIdentifier) as? FamilyTestsHomeCell else {
			fatalError("Failed to get FamilyTestsHomeCell")
		}
		cell.configure(
			with: FamilyTestsHomeCellViewModel(
				familyMemberCoronaTestService: viewModel.familyMemberCoronaTestService,
				onUpdate: { [weak self] in
					self?.animateChanges(of: cell)
				}
			)
		)
		return cell
	}

	private func testResultCell(
		forRowAt indexPath: IndexPath,
		coronaTestType: CoronaTestType
	) -> UITableViewCell {
		switch coronaTestType {
		case .pcr:
			if let cell = pcrTestResultCell {
				return cell
			}
		case .antigen:
			if let cell = antigenTestResultCell {
				return cell
			}
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTestResultTableViewCell.self), for: indexPath) as? HomeTestResultTableViewCell else {
			fatalError("Could not dequeue HomeTestResultTableViewCell")
		}

		let cellModel = HomeTestResultCellModel(
			coronaTestType: coronaTestType,
			coronaTestService: viewModel.coronaTestService,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				guard let self = self else { return }

				if self.viewModel.shouldShowDeletionConfirmationAlert(for: coronaTestType) {
					self.showDeletionConfirmationAlert(for: coronaTestType)
				} else {
					self.viewModel.didTapTestResultButton(coronaTestType: coronaTestType)
				}
			}
		)

		switch coronaTestType {
		case .pcr:
			pcrTestResultCell = cell
		case .antigen:
			antigenTestResultCell = cell
		}

		return cell
	}

	private func shownPositiveTestResultCell(
		forRowAt indexPath: IndexPath,
		coronaTestType: CoronaTestType
	) -> UITableViewCell {
		switch coronaTestType {
		case .pcr:
			if let cell = pcrTestShownPositiveResultCell {
				return cell
			}
		case .antigen:
			if let cell = antigenTestShownPositiveResultCell {
				return cell
			}
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeShownPositiveTestResultTableViewCell.self), for: indexPath) as? HomeShownPositiveTestResultTableViewCell else {
			fatalError("Could not dequeue HomeShownPositiveTestResultTableViewCell")
		}

		let cellModel = HomeShownPositiveTestResultCellModel(
			coronaTestType: coronaTestType,
			coronaTestService: viewModel.coronaTestService,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				self?.viewModel.didTapTestResultButton(coronaTestType: coronaTestType)
			},
			onSecondaryAction: { [weak self] in
				let alert = UIAlertController(
					title: AppStrings.ExposureSubmissionResult.removeAlert_Title,
					message: AppStrings.ExposureSubmissionResult.removeAlert_Text,
					preferredStyle: .alert
				)
				
				let deleteAction = UIAlertAction(
					title: AppStrings.ExposureSubmissionResult.removeAlert_ConfirmButtonTitle,
					style: .destructive,
					handler: { [weak self] _ in
						self?.viewModel.coronaTestService.moveTestToBin(coronaTestType)
					}
				)
				deleteAction.accessibilityIdentifier = AccessibilityIdentifiers.Home.ShownPositiveTestResultCell.deleteAlertDeleteButton
				alert.addAction(deleteAction)
				
				let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
				alert.addAction(cancelAction)
				
				self?.present(alert, animated: true, completion: nil)
			}
		)

		switch coronaTestType {
		case .pcr:
			pcrTestShownPositiveResultCell = cell
		case .antigen:
			antigenTestShownPositiveResultCell = cell
		}

		return cell
	}

	private func testRegistrationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTestRegistrationTableViewCell.self), for: indexPath) as? HomeTestRegistrationTableViewCell else {
			fatalError("Could not dequeue HomeTraceLocationsTableViewCell")
		}

		cell.configure(
			with: HomeTestRegistrationCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onTestRegistrationCellTap()
			}
		)

		return cell
	}

	private func statisticsCell(forRowAt indexPath: IndexPath) -> HomeStatisticsTableViewCell {
		let cellHeight = viewModel.heightForRow(at: indexPath)
		if let statisticsCell = statisticsCell {
			statisticsCell.isHidden = cellHeight == 0
			return statisticsCell
		}

		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeStatisticsTableViewCell.self), for: indexPath) as? HomeStatisticsTableViewCell else {
			fatalError("Could not dequeue HomeStatisticsTableViewCell")
		}
		Log.debug("Configure statistics cell", log: .localStatistics)

		cell.configure(
			with: HomeStatisticsCellModel(
				homeState: viewModel.state,
				localStatisticsProvider: viewModel.state.localStatisticsProvider
			),
			store: viewModel.store,
			onInfoButtonTap: { [weak self] in
				self?.onStatisticsInfoButtonTap()
			},
			onAddLocalStatisticsButtonTap: { [weak self] selectValueViewController in
				self?.onAddStateButtonTap(selectValueViewController)
				self?.statisticsCell?.updateManagementCellState()
			},
			onAddDistrict: { [weak self] selectValueViewController in
				self?.onAddDistrict(selectValueViewController)
				self?.statisticsCell?.updateManagementCellState()
			},
			onDismissState: { [weak self] in
				self?.onDismissState()
			},
			onDismissDistrict: { [weak self] dismissToRoot in
				self?.onDismissDistrict(dismissToRoot)
			},
			onAccessibilityFocus: { [weak self] in
				self?.tableView.contentOffset.x = 0
				self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
			},
			onUpdate: { [weak self] in
				DispatchQueue.main.async { [weak self] in
					let isEditing = HomeStatisticsTableViewCell.editingStatistics
					self?.tableView.reloadSections([HomeTableViewModel.Section.statistics.rawValue], with: .none)
					self?.statisticsCell?.setEditing(isEditing, animated: false)
					self?.statisticsCell?.updateManagementCellState()
				}
			}
		)
		
		cell.isHidden = cellHeight == 0

		statisticsCell = cell

		return cell
	}

	private func traceLocationsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTraceLocationsTableViewCell.self), for: indexPath) as? HomeTraceLocationsTableViewCell else {
			fatalError("Could not dequeue HomeTraceLocationsTableViewCell")
		}

		cell.configure(
			with: HomeTraceLocationsCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onTraceLocationsCellTap()
			}
		)

		return cell
	}

	private func moreInfoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeMoreInfoTableViewCell.self), for: indexPath) as? HomeMoreInfoTableViewCell else {
			fatalError("Could not dequeue HomeMoreInfoTableViewCell")
		}
		cell.configure(onItemTap: { [weak self] selectedItem in
			guard let self = self else { return }
			switch selectedItem {
			case .settings:
				self.onSettingsCellTap(self.viewModel.state.enState)
			case .recycleBin:
				self.onRecycleBinCellTap()
			case .appInformation:
				self.onAppInformationCellTap()
			case .faq:
				self.onFAQCellTap()
			case .socialMedia:
				self.onSocialMediaCellTap()
			case .share:
				self.onInviteFriendsCellTap()
			}
		})
		return cell
	}

	@IBAction private func infoButtonTapped() {
		onInfoBarButtonItemTap()
	}

	private func showRouteIfNeeded(completion: @escaping () -> Void) {
		defer {
			route = nil
		}

		// handle error -> show alert & trigger the chain
		switch route {
		case .rapidAntigen(let testResult), .rapidPCR(let testResult):
			showTestInformationResult(testResult)
		case .testResultFromNotification,
			 .checkIn,
			 .healthCertificateFromNotification,
			 .healthCertifiedPersonFromNotification,
			 .none:
			break
		}
		completion()
	}

	private func showDeltaOnboardingIfNeeded(completion: @escaping () -> Void = {}) {
		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
			guard let self = self else {
				Log.debug("Skip onboarding call, because HomeTableViewController was deallocated.", log: .onboarding)
				completion()
				return
			}

			let supportedCountries = configuration.supportedCountries.compactMap({ Country(countryCode: $0) })

			/// As per feature requirement, the delta onboarding should appear with a slight delay of 0.5
			var delay = 0.5

			#if DEBUG
			if isUITesting {
				/// In UI Testing we need to increase the delay slightly again. Otherwise UI Tests fail.
				delay = 1.5
			}
			#endif

			let onboardings: [DeltaOnboarding] = [
				DeltaOnboardingNewVersionFeatures(store: self.viewModel.store),
				DeltaOnboardingNotificationRework(store: self.viewModel.store),
				DeltaOnboardingCrossCountrySupport(store: self.viewModel.store, supportedCountries: supportedCountries),
				DeltaOnboardingDataDonation(store: self.viewModel.store)
			]

			Log.debug("Delta Onboarding list size: \(onboardings.count)", log: .onboarding)

			self.deltaOnboardingCoordinator = DeltaOnboardingCoordinator(
				rootViewController: self,
				onboardings: onboardings,
				store: self.viewModel.store
			)

			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				guard self.presentedViewController == nil else {
					Log.debug("Don't show onboarding this time, because another view controller is currently presented.", log: .onboarding)
					completion()
					return
				}

				self.deltaOnboardingCoordinator?.finished = {
					Log.debug("Onboarding finished.", log: .onboarding)
					completion()
				}

				Log.debug("Start onboarding.", log: .onboarding)
				self.deltaOnboardingCoordinator?.startOnboarding()
			}
		}.store(in: &subscriptions)
	}

	private func showInformationHowRiskDetectionWorksIfNeeded(completion: @escaping () -> Void = {}) {
		guard viewModel.store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
			completion()
			return
		}
		
		appConfigurationProvider.appConfiguration().sink { [weak self] appConfig in
			guard let self = self else {
				completion()
				return
			}
			
			let title = AppStrings.Home.riskDetectionHowToAlertTitle
			let message = String(
				format: AppStrings.Home.riskDetectionHowToAlertMessage,
				appConfig.riskCalculationParameters.defaultedMaxEncounterAgeInDays
			)
			
			let alert = UIAlertController(
				title: title,
				message: message,
				preferredStyle: .alert
			)
			
			alert.addAction(
				UIAlertAction(
					title: NSLocalizedString("Alert_ActionOk", comment: ""),
					style: .default,
					handler: { _ in
						completion()
					}
				)
			)
			
			self.present(alert, animated: true) { [weak self] in
				self?.viewModel.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
			}
		}.store(in: &subscriptions)
	}

	/// This method checks whether the below conditions in regards to background fetching have been met
	/// and shows the corresponding alert.
	private func showBackgroundFetchAlertIfNeeded(completion: @escaping () -> Void = {}) {
		let status = UIApplication.shared.backgroundRefreshStatus
		let inLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
		let hasSeenAlertBefore = viewModel.store.hasSeenBackgroundFetchAlert

		/// The error alert should only be shown:
		/// - once
		/// - if the background refresh is disabled
		/// - if the user is __not__ in power saving mode, because in this case the background
		///   refresh is disabled automatically. Therefore we have to explicitly check this.
		if status == .available || inLowPowerMode || hasSeenAlertBefore {
			completion()
			return
		}

		let alert = setupErrorAlert(
			title: AppStrings.Common.backgroundFetch_AlertTitle,
			message: AppStrings.Common.backgroundFetch_AlertMessage,
			okTitle: AppStrings.Common.backgroundFetch_OKTitle,
			secondaryActionTitle: AppStrings.Common.backgroundFetch_SettingsTitle,
			secondaryActionCompletion: {
				LinkHelper.open(urlString: UIApplication.openSettingsURLString)
			}
		)

		self.present(
			alert,
			animated: true,
			completion: { [weak self] in
				self?.viewModel.store.hasSeenBackgroundFetchAlert = true
				completion()
			}
		)
	}

	private func showAnotherHighExposureAlertIfNeeded(completion: @escaping () -> Void) {
		guard viewModel.store.showAnotherHighExposureAlert else {
			completion()
			return
		}

		let currentAppConfig = appConfigurationProvider.currentAppConfig.value

		let alert = UIAlertController(
			title: AppStrings.Home.riskStatusAnotherHighExposureAlertTitle,
			message: String(format: AppStrings.Home.riskStatusAnotherHighExposureAlertMessage, currentAppConfig.riskCalculationParameters.defaultedMaxEncounterAgeInDays),
			preferredStyle: .alert
		)

		let alertAction = UIAlertAction(
			title: AppStrings.Home.riskStatusAnotherHighExposureButtonTitle,
			style: .default,
			handler: { _ in
				completion()
			}
		)
		alert.addAction(alertAction)
		alertAction.accessibilityIdentifier = AccessibilityIdentifiers.Home.Alerts.anotherHighExposureButtonOK

		present(alert, animated: true) { [weak self] in
			self?.viewModel.store.showAnotherHighExposureAlert = false
		}

	}

	private func showRiskStatusLoweredAlertIfNeeded(completion: @escaping () -> Void = {}) {
		guard viewModel.store.shouldShowRiskStatusLoweredAlert else {
			completion()
			return
		}

		guard !viewModel.riskStatusLoweredAlertShouldBeSuppressed else {
			viewModel.store.shouldShowRiskStatusLoweredAlert = false
			completion()
			return
		}

		let currentAppConfig = appConfigurationProvider.currentAppConfig.value

		let alert = UIAlertController(
			title: AppStrings.Home.riskStatusLoweredAlertTitle,
			message: String(format: AppStrings.Home.riskStatusLoweredAlertMessage, currentAppConfig.riskCalculationParameters.defaultedMaxEncounterAgeInDays),
			preferredStyle: .alert
		)

		let alertAction = UIAlertAction(
			title: AppStrings.Home.riskStatusLoweredAlertPrimaryButtonTitle,
			style: .default,
			handler: { _ in
				completion()
			}
		)
		alert.addAction(alertAction)

		present(alert, animated: true) { [weak self] in
			self?.viewModel.store.shouldShowRiskStatusLoweredAlert = false
		}
	}

	private func showQRScannerTooltipIfNeeded(completion: @escaping () -> Void = {}) {
		guard viewModel.store.shouldShowQRScannerTooltip,
			let tabBar = tabBarController?.tabBar else {
			completion()
			return
		}

		let tooltipViewController = QRScannerTooltipViewController(
			onDismiss: { [weak self] in
				self?.dismiss(animated: true) {
					completion()
				}
			}
		)

		tooltipViewController.popoverPresentationController?.sourceView = tabBar
		tooltipViewController.popoverPresentationController?.sourceRect = tabBar.bounds

		present(tooltipViewController, animated: true) { [weak self] in
			self?.viewModel.store.shouldShowQRScannerTooltip = false
		}
	}

	private func showDeletionConfirmationAlert(for coronaTestType: CoronaTestType) {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionResult.removeAlert_Title,
			message: AppStrings.ExposureSubmissionResult.removeAlert_Text,
			preferredStyle: .alert
		)

		let cancelAction = UIAlertAction(
			title: AppStrings.Common.alertActionCancel,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)

		let deleteAction = UIAlertAction(
			title: AppStrings.ExposureSubmissionResult.removeAlert_ConfirmButtonTitle,
			style: .destructive,
			handler: { [weak self] _ in
				self?.viewModel.moveTestToBin(type: coronaTestType)
			}
		)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		present(alert, animated: true, completion: nil)
	}
	
	func showStartupErrorsIfNeeded(completion: @escaping () -> Void) {
		showErrors(startupErrors) { [weak self] in
			guard let self = self else {
				completion()
				return
			}
			self.startupErrors.removeAll()
			completion()
		}
	}
	
	func showErrors(_ errors: [Error], completion: @escaping () -> Void) {
		var mutableErrors = errors
		guard let firstError = mutableErrors.first else {
			completion()
			return
		}
		mutableErrors.removeFirst()
		
		let alert = UIAlertController(
			title: AppStrings.Common.alertTitleGeneral,
			message: firstError.localizedDescription,
			preferredStyle: .alert
		)
		let okAction = UIAlertAction(title: AppStrings.Common.alertActionOk, style: .default) { [weak self] _ in
			guard let self = self else {
				completion()
				return
			}
			self.showErrors(mutableErrors, completion: completion)
		}
		alert.addAction(okAction)
		self.present(alert, animated: true)
	}

	@objc
	private func refreshUIAfterResumingFromBackground() {
		refreshUI()
		showDeltaOnboardingAndAlertsIfNeeded()
	}
	
	@objc
	private func refreshUI() {
		Log.info("Refresh UI.")

		DispatchQueue.main.async { [weak self] in
			self?.viewModel.updateTestResult()
			self?.viewModel.state.updateStatistics()
		}
	}
	// swiftlint:disable:next file_length
}
