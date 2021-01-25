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
		onInfoBarButtonItemTap: @escaping () -> Void,
		onExposureDetectionCellTap: @escaping (ENStateHandler.State) -> Void,
		onRiskCellTap: @escaping (HomeState) -> Void,
		onInactiveCellButtonTap: @escaping (ENStateHandler.State) -> Void,
		onTestResultCellTap: @escaping (TestResult?) -> Void,
		onStatisticsInfoButtonTap: @escaping () -> Void,
		onDiaryCellTap: @escaping () -> Void,
		onInviteFriendsCellTap: @escaping () -> Void,
		onFAQCellTap: @escaping () -> Void,
		onAppInformationCellTap: @escaping () -> Void,
		onSettingsCellTap: @escaping (ENStateHandler.State) -> Void
	) {
		self.viewModel = viewModel
		self.appConfigurationProvider = appConfigurationProvider

		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onExposureDetectionCellTap = onExposureDetectionCellTap
		self.onRiskCellTap = onRiskCellTap
		self.onInactiveCellButtonTap = onInactiveCellButtonTap
		self.onTestResultCellTap = onTestResultCellTap
		self.onStatisticsInfoButtonTap = onStatisticsInfoButtonTap
		self.onDiaryCellTap = onDiaryCellTap
		self.onInviteFriendsCellTap = onInviteFriendsCellTap
		self.onFAQCellTap = onFAQCellTap
		self.onAppInformationCellTap = onAppInformationCellTap
		self.onSettingsCellTap = onSettingsCellTap

		super.init(style: .plain)

		viewModel.state.$testResult
			.sink { [weak self] _ in
				DispatchQueue.main.async {
					self?.reload()
				}
			}
			.store(in: &subscriptions)

		viewModel.state.$testResultLoadingError
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] testResultLoadingError in
				guard let self = self, let testResultLoadingError = testResultLoadingError else { return }

				self.viewModel.state.testResultLoadingError = nil

				switch testResultLoadingError {
				case .error(let error):
					self.alertError(
						message: error.localizedDescription,
						title: AppStrings.Home.resultCardLoadingErrorTitle
					)
				case .expired:
					self.alertError(
						message: AppStrings.ExposureSubmissionResult.testExpiredDesc,
						title: AppStrings.Home.resultCardLoadingErrorTitle
					)
				}
			}
			.store(in: &subscriptions)

		viewModel.state.$statistics
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { [weak self] newStatistics in
				// Only reload if stats change
				guard newStatistics != viewModel.state.statistics else {
					return
				}
				self?.reload()
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
		tableView.backgroundColor = .enaColor(for: .separator)

		NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterResumingFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)

		viewModel.state.updateTestResult()
		viewModel.state.updateStatistics()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		/** navigationbar is a shared property - so we need to trigger a resizing because others could have set it to true*/
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.sizeToFit()

		viewModel.state.requestRisk(userInitiated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

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
			return exposureDetectionCell(forRowAt: indexPath)
		case .riskAndTest:
			switch viewModel.riskAndTestRows[indexPath.row] {
			case .risk:
				return riskCell(forRowAt: indexPath)
			case .testResult:
				return testResultCell(forRowAt: indexPath)
			case .shownPositiveTestResult:
				return shownPositiveTestResultCell(forRowAt: indexPath)
			case .thankYou:
				return thankYouCell(forRowAt: indexPath)
			}
		case .statistics:
			return statisticsCell(forRowAt: indexPath)
		case .diary:
			return diaryCell(forRowAt: indexPath)
		case .infos:
			return infoCell(forRowAt: indexPath)
		case .settings:
			return infoCell(forRowAt: indexPath)
		default:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		UIView()
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return viewModel.heightForHeader(in: section)
	}

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		UIView()
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return viewModel.heightForFooter(in: section)
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return viewModel.heightForRow(at: indexPath)
	}

	// MARK: - Protocol UITableViewDelegate
	
	// swiftlint:disable:next cyclomatic_complexity
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .exposureLogging:
			onExposureDetectionCellTap(viewModel.state.enState)
		case .riskAndTest:
			switch viewModel.riskAndTestRows[indexPath.row] {
			case .risk:
				onRiskCellTap(viewModel.state)
			case .testResult, .shownPositiveTestResult:
				onTestResultCellTap(viewModel.state.testResult)
			case .thankYou:
				break
			}
		case .statistics:
			break
		case .diary:
			onDiaryCellTap()
		case .infos:
			if indexPath.row == 0 {
				onInviteFriendsCellTap()
			} else {
				onFAQCellTap()
			}
		case .settings:
			if indexPath.row == 0 {
				onAppInformationCellTap()
			} else {
				onSettingsCellTap(viewModel.state.enState)
			}
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

	func reload() {
		tableView.reloadData()
	}

	func scrollToTop(animated: Bool) {
		tableView.setContentOffset(.zero, animated: animated)
	}
	
	// MARK: - Private

	private let viewModel: HomeTableViewModel
	private let appConfigurationProvider: AppConfigurationProviding

	private let onInfoBarButtonItemTap: () -> Void
	private let onExposureDetectionCellTap: (ENStateHandler.State) -> Void
	private let onRiskCellTap: (HomeState) -> Void
	private let onInactiveCellButtonTap: (ENStateHandler.State) -> Void
	private let onTestResultCellTap: (TestResult?) -> Void
	private let onStatisticsInfoButtonTap: () -> Void
	private let onDiaryCellTap: () -> Void
	private let onInviteFriendsCellTap: () -> Void
	private let onFAQCellTap: () -> Void
	private let onAppInformationCellTap: () -> Void
	private let onSettingsCellTap: (ENStateHandler.State) -> Void

	private var deltaOnboardingCoordinator: DeltaOnboardingCoordinator?

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
			UINib(nibName: String(describing: HomeThankYouTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeThankYouTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeStatisticsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeStatisticsTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeDiaryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeDiaryTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeInfoTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension

		// Overestimate to fix auto layout warnings and fix a problem that showed the diary cell behind other cells when opening app from the background in manual mode
		tableView.estimatedRowHeight = 500
	}

	private func animateChanges(of cell: UITableViewCell) {
		// DispatchQueue prevents undefined behaviour in `visibleCells` while cells are being updated
		// https://developer.apple.com/forums/thread/117537
		DispatchQueue.main.async { [self] in
			guard tableView.visibleCells.contains(cell) else {
				return
			}

			// Only animate changes as long as the risk and the test result cell are both still supposed to be there, otherwise reload the table view
			guard viewModel.riskAndTestRows.count == 2 else {
				tableView.reloadData()
				return
			}

			// Animate the changed cell height
			tableView.performBatchUpdates(nil, completion: nil)

			// Keep the other visible cells maskToBounds off during the animation to avoid flickering shadows due to them being cut off (https://stackoverflow.com/a/59581645)
			for cell in tableView.visibleCells {
				cell.layer.masksToBounds = false
				cell.contentView.layer.masksToBounds = false
			}
		}
	}

	private func exposureDetectionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeExposureLoggingTableViewCell.self), for: indexPath) as? HomeExposureLoggingTableViewCell else {
			fatalError("Could not dequeue HomeExposureLoggingTableViewCell")
		}

		cell.configure(with: HomeExposureLoggingCellModel(state: viewModel.state))

		return cell
	}

	private func riskCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
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

		return cell
	}

	private func testResultCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTestResultTableViewCell.self), for: indexPath) as? HomeTestResultTableViewCell else {
			fatalError("Could not dequeue HomeTestResultTableViewCell")
		}

		let cellModel = HomeTestResultCellModel(
			homeState: viewModel.state,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			with: cellModel,
			onPrimaryAction: { [weak self] in
				guard let self = self else { return }
				self.onTestResultCellTap(self.viewModel.state.testResult)
			}
		)

		return cell
	}

	private func shownPositiveTestResultCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeShownPositiveTestResultTableViewCell.self), for: indexPath) as? HomeShownPositiveTestResultTableViewCell else {
			fatalError("Could not dequeue HomeShownPositiveTestResultTableViewCell")
		}

		cell.configure(
			with: HomeShownPositiveTestResultCellModel(),
			onPrimaryAction: { [weak self] in
				guard let self = self else { return }
				self.onTestResultCellTap(self.viewModel.state.testResult)
			}
		)

		return cell
	}

	private func thankYouCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeThankYouTableViewCell.self), for: indexPath) as? HomeThankYouTableViewCell else {
			fatalError("Could not dequeue HomeThankYouTableViewCell")
		}

		let cellModel = HomeThankYouCellModel()
		cell.configure(with: cellModel)

		return cell
	}

	private func statisticsCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeStatisticsTableViewCell.self), for: indexPath) as? HomeStatisticsTableViewCell else {
			fatalError("Could not dequeue HomeStatisticsTableViewCell")
		}

		cell.configure(
			with: HomeStatisticsCellModel(homeState: viewModel.state),
			onInfoButtonTap: { [weak self] in
				self?.onStatisticsInfoButtonTap()
			},
			onAccessibilityFocus: { [weak self] in
				self?.tableView.contentOffset.x = 0
				self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
			},
			onUpdate: { [weak self] in
				self?.tableView.reloadSections([HomeTableViewModel.Section.statistics.rawValue], with: .none)
			}
		)

		return cell
	}

	private func diaryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeDiaryTableViewCell.self), for: indexPath) as? HomeDiaryTableViewCell else {
			fatalError("Could not dequeue HomeDiaryTableViewCell")
		}

		cell.configure(
			with: HomeDiaryCellModel(),
			onPrimaryAction: { [weak self] in
				self?.onDiaryCellTap()
			}
		)

		return cell
	}

	private func infoCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeInfoTableViewCell.self), for: indexPath) as? HomeInfoTableViewCell else {
			fatalError("Could not dequeue HomeInfoTableViewCell")
		}

		switch HomeTableViewModel.Section(rawValue: indexPath.section) {
		case .infos:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .inviteFriends))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .faq))
			}
		case .settings:
			if indexPath.row == 0 {
				cell.configure(with: HomeInfoCellModel(infoCellType: .appInformation))
			} else {
				cell.configure(with: HomeInfoCellModel(infoCellType: .settings))
			}
		default:
			fatalError("Invalid section")
		}

		return cell
	}

	@IBAction private func infoButtonTapped() {
		onInfoBarButtonItemTap()
	}

	private func showDeltaOnboardingAndAlertsIfNeeded() {
		showDeltaOnboardingIfNeeded(completion: { [weak self] in
			self?.showInformationHowRiskDetectionWorksIfNeeded(completion: {
				self?.showBackgroundFetchAlertIfNeeded(completion: {
					self?.showRiskStatusLoweredAlertIfNeeded()
				})
			})
		})
	}

	private func showDeltaOnboardingIfNeeded(completion: @escaping () -> Void = {}) {
		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
			guard let self = self else { return }

			let supportedCountries = configuration.supportedCountries.compactMap({ Country(countryCode: $0) })

			// As per feature requirement, the delta onboarding should appear with a slight delay of 0.5
			var delay = 0.5

			#if DEBUG
			if isUITesting {
				// In UI Testing we need to increase the delaye slightly again.
				// Otherwise UI Tests fail
				delay = 1.5
			}
			#endif

			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
				let onboardings: [DeltaOnboarding] = [
					DeltaOnboardingV15(store: self.viewModel.state.store, supportedCountries: supportedCountries)
				]

				self.deltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: self, onboardings: onboardings)
				self.deltaOnboardingCoordinator?.finished = { [weak self] in
					self?.deltaOnboardingCoordinator = nil
					completion()
				}

				self.deltaOnboardingCoordinator?.startOnboarding()
			}
		}.store(in: &subscriptions)
	}

	private func showInformationHowRiskDetectionWorksIfNeeded(completion: @escaping () -> Void = {}) {
		#if DEBUG
		if isUITesting, let showInfo = UserDefaults.standard.string(forKey: "userNeedsToBeInformedAboutHowRiskDetectionWorks") {
			viewModel.state.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = (showInfo == "YES")
		}
		#endif

		guard viewModel.state.store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
			completion()
			return
		}

		let title = NSLocalizedString("How_Risk_Detection_Works_Alert_Title", comment: "")
		let message = String(
			format: NSLocalizedString(
				"How_Risk_Detection_Works_Alert_Message",
				comment: ""
			),
			TracingStatusHistory.maxStoredDays
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

		present(alert, animated: true) { [weak self] in
			self?.viewModel.state.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
		}
	}

	/// This method checks whether the below conditions in regards to background fetching have been met
	/// and shows the corresponding alert.
	private func showBackgroundFetchAlertIfNeeded(completion: @escaping () -> Void = {}) {
		let status = UIApplication.shared.backgroundRefreshStatus
		let inLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
		let hasSeenAlertBefore = viewModel.state.store.hasSeenBackgroundFetchAlert

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
			completion: { [weak self] in
				self?.viewModel.state.store.hasSeenBackgroundFetchAlert = true
				completion()
			},
			secondaryActionCompletion: {
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
		)

		self.present(
			alert,
			animated: true,
			completion: nil
		)
	}

	private func showRiskStatusLoweredAlertIfNeeded(completion: @escaping () -> Void = {}) {
		guard viewModel.state.store.shouldShowRiskStatusLoweredAlert else {
			completion()
			return
		}

		let alert = UIAlertController(
			title: AppStrings.Home.riskStatusLoweredAlertTitle,
			message: AppStrings.Home.riskStatusLoweredAlertMessage,
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
			self?.viewModel.state.store.shouldShowRiskStatusLoweredAlert = false
		}
	}

	@objc
	private func refreshUIAfterResumingFromBackground() {
		viewModel.state.updateTestResult()
		viewModel.state.updateStatistics()
		showDeltaOnboardingAndAlertsIfNeeded()
	}

	// swiftlint:disable:next file_length
}
