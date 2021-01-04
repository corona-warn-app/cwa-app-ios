////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeTableViewController: UITableViewController, NavigationBarOpacityDelegate {

	// MARK: - Init

	init(
		viewModel: HomeTableViewModel,
		onInfoBarButtonItemTap: @escaping () -> Void,
		onExposureDetectionCellTap: @escaping (ENStateHandler.State) -> Void,
		onRiskCellTap: @escaping (HomeState) -> Void,
		onInactiveCellButtonTap: @escaping (ENStateHandler.State) -> Void,
		onTestResultCellTap: @escaping (TestResult?) -> Void,
		onDiaryCellTap: @escaping () -> Void,
		onInviteFriendsCellTap: @escaping () -> Void,
		onFAQCellTap: @escaping () -> Void,
		onAppInformationCellTap: @escaping () -> Void,
		onSettingsCellTap: @escaping (ENStateHandler.State) -> Void
	) {
		self.viewModel = viewModel

		self.onInfoBarButtonItemTap = onInfoBarButtonItemTap
		self.onExposureDetectionCellTap = onExposureDetectionCellTap
		self.onRiskCellTap = onRiskCellTap
		self.onInactiveCellButtonTap = onInactiveCellButtonTap
		self.onTestResultCellTap = onTestResultCellTap
		self.onDiaryCellTap = onDiaryCellTap
		self.onInviteFriendsCellTap = onInviteFriendsCellTap
		self.onFAQCellTap = onFAQCellTap
		self.onAppInformationCellTap = onAppInformationCellTap
		self.onSettingsCellTap = onSettingsCellTap

		super.init(style: .plain)

		viewModel.state.$testResultLoadingError
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

		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = .enaColor(for: .separator)

		setupBackgroundFetchAlert()

		NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.state.updateTestResult()
		viewModel.state.requestRisk(userInitiated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		showInformationHowRiskDetectionWorks()
		showDeltaOnboarding()
		showRiskStatusLoweredAlertIfNeeded()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

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

	func scrollToTop(animated: Bool) {
		tableView.setContentOffset(.zero, animated: animated)
	}
	
	// MARK: - Private

	private let onInfoBarButtonItemTap: () -> Void
	private let onExposureDetectionCellTap: (ENStateHandler.State) -> Void
	private let onRiskCellTap: (HomeState) -> Void
	private let onInactiveCellButtonTap: (ENStateHandler.State) -> Void
	private let onTestResultCellTap: (TestResult?) -> Void
	private let onDiaryCellTap: () -> Void
	private let onInviteFriendsCellTap: () -> Void
	private let onFAQCellTap: () -> Void
	private let onAppInformationCellTap: () -> Void
	private let onSettingsCellTap: (ENStateHandler.State) -> Void

	private let viewModel: HomeTableViewModel

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
			UINib(nibName: String(describing: HomeDiaryTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeDiaryTableViewCell.self)
		)
		tableView.register(
			UINib(nibName: String(describing: HomeInfoTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: HomeInfoTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
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
				guard let self = self, self.tableView.visibleCells.contains(cell) else { return }
				// Updates the cell height whenever the content of the cell changes
				self.tableView.beginUpdates()
				self.tableView.endUpdates()
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
				guard let self = self, self.tableView.visibleCells.contains(cell) else { return }
				// Updates the cell height whenever the content of the cell changes
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
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

	private func showInformationHowRiskDetectionWorks() {
//		#if DEBUG
//		if isUITesting, let showInfo = UserDefaults.standard.string(forKey: "userNeedsToBeInformedAboutHowRiskDetectionWorks") {
//			store.userNeedsToBeInformedAboutHowRiskDetectionWorks = (showInfo == "YES")
//		}
//		#endif
//
//		guard store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
//			return
//		}
//
//		let alert = UIAlertController.localizedHowRiskDetectionWorksAlertController(
//			maximumNumberOfDays: TracingStatusHistory.maxStoredDays
//		)
//
//		present(alert, animated: true) {
//			self.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
//		}
	}

	private func showDeltaOnboarding() {
//		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
//			guard let self = self else { return }
//
//			let supportedCountries = configuration.supportedCountries.compactMap({ Country(countryCode: $0) })
//
//			// As per feature requirement, the delta onboarding should appear with a slight delay of 0.5
//			var delay = 0.5
//
//			#if DEBUG
//			if isUITesting {
//				// In UI Testing we need to increase the delaye slightly again.
//				// Otherwise UI Tests fail
//				delay = 1.5
//			}
//			#endif
//
//			DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//				let onboardings: [DeltaOnboarding] = [
//					DeltaOnboardingV15(store: self.store, supportedCountries: supportedCountries)
//				]
//
//				self.deltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: self, onboardings: onboardings)
//				self.deltaOnboardingCoordinator?.finished = { [weak self] in
//					self?.deltaOnboardingCoordinator = nil
//				}
//
//				self.deltaOnboardingCoordinator?.startOnboarding()
//			}
//		}.store(in: &subscriptions)
	}

	/// This method sets up a background fetch alert, and presents it, if needed.
	/// Check the `createBackgroundFetchAlert` method for more information.
	private func setupBackgroundFetchAlert() {
//		guard let alert = createBackgroundFetchAlert(
//			status: UIApplication.shared.backgroundRefreshStatus,
//			inLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
//			hasSeenAlertBefore: homeInteractor.store.hasSeenBackgroundFetchAlert,
//			store: homeInteractor.store
//			) else { return }
//
//		self.present(
//			alert,
//			animated: true,
//			completion: nil
//		)
	}

	func showRiskStatusLoweredAlertIfNeeded() {
//		guard store.shouldShowRiskStatusLoweredAlert else { return }
//
//		let alert = UIAlertController(
//			title: AppStrings.Home.riskStatusLoweredAlertTitle,
//			message: AppStrings.Home.riskStatusLoweredAlertMessage,
//			preferredStyle: .alert
//		)
//
//		let alertAction = UIAlertAction(
//			title: AppStrings.Home.riskStatusLoweredAlertPrimaryButtonTitle,
//			style: .default
//		)
//		alert.addAction(alertAction)
//
//		present(alert, animated: true) { [weak self] in
//			self?.store.shouldShowRiskStatusLoweredAlert = false
//		}
	}

	@objc
	private func refreshUIAfterResumingFromBackground() {
		viewModel.state.updateTestResult()
	}

}
