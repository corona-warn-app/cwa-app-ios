//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import OpenCombine
import DiffableDataSources
import UIKit

protocol HomeViewControllerDelegate: AnyObject {
	func showRiskLegend()
	func showExposureNotificationSetting(enState: ENStateHandler.State)
	func showExposureDetection(state: HomeInteractor.State, activityState: RiskProviderActivityState)
	func setExposureDetectionState(state: HomeInteractor.State, activityState: RiskProviderActivityState)
	func showExposureSubmission(with result: TestResult?)
	func showDiary()
	func showInviteFriends()
	func showWebPage(from viewController: UIViewController, urlString: String)
	func showAppInformation()
	func showSettings(enState: ENStateHandler.State)
	func addToEnStateUpdateList(_ anyObject: AnyObject?)
}

final class HomeViewController: UICollectionViewController, RequiresAppDependencies {
	// MARK: Creating a Home View Controller
	init(
		delegate: HomeViewControllerDelegate,
		exposureManagerState: ExposureManagerState,
		initialEnState: ENStateHandler.State,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.delegate = delegate

		super.init(collectionViewLayout: .init())

		var riskState: RiskState
		if let riskCalculationResult = store.riskCalculationResult {
			riskState = .risk(
				Risk(
					activeTracing: store.tracingStatusHistory.activeTracing(),
					riskCalculationResult: riskCalculationResult
				)
			)
		} else {
			riskState = .risk(
				Risk(
					level: .low,
					details: .init(
						mostRecentDateWithRiskLevel: nil,
						numberOfDaysWithRiskLevel: 0,
						activeTracing: store.tracingStatusHistory.activeTracing(),
						exposureDetectionDate: nil
					),
					riskLevelHasChanged: false
				)
			)
		}

		self.homeInteractor = HomeInteractor(
			homeViewController: self,
			state: .init(
				riskState: riskState,
				exposureManagerState: exposureManagerState,
				enState: initialEnState
			),
			exposureSubmissionService: exposureSubmissionService,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		navigationItem.largeTitleDisplayMode = .never
		delegate.addToEnStateUpdateList(homeInteractor)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	private var sections: HomeInteractor.SectionConfiguration = []
	private var dataSource: CollectionViewDiffableDataSource<Section, AnyHashable>?
	private var homeInteractor: HomeInteractor!
	private var deltaOnboardingCoordinator: DeltaOnboardingCoordinator?

	private var subscriptions = [AnyCancellable]()

	private weak var delegate: HomeViewControllerDelegate?

	enum Section: Int {
		case actions
		case infos
		case settings
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBarButtonItems()
		setupBackgroundFetchAlert()
		configureCollectionView()
		configureDataSource()
		setupAccessibility()

		homeInteractor.buildSections()
		updateSections()
		applySnapshotFromSections()

		setStateOfChildViewControllers()
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(refreshUIAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		homeInteractor.updateTestResults()
		homeInteractor.requestRisk(userInitiated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		showInformationHowRiskDetectionWorks()
		showDeltaOnboarding()
	}

	private func showInformationHowRiskDetectionWorks() {
		
		#if DEBUG
		if isUITesting, let showInfo = UserDefaults.standard.string(forKey: "userNeedsToBeInformedAboutHowRiskDetectionWorks") {
			store.userNeedsToBeInformedAboutHowRiskDetectionWorks = (showInfo == "YES")
		}
		#endif
		
		guard store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
			return
		}

		let alert = UIAlertController.localizedHowRiskDetectionWorksAlertController(
			maximumNumberOfDays: TracingStatusHistory.maxStoredDays
		)

		present(alert, animated: true) {
			self.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
		}
	}

	private func showDeltaOnboarding() {
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
					DeltaOnboardingV15(store: self.store, supportedCountries: supportedCountries)
				]

				self.deltaOnboardingCoordinator = DeltaOnboardingCoordinator(rootViewController: self, onboardings: onboardings)
				self.deltaOnboardingCoordinator?.finished = { [weak self] in
					self?.deltaOnboardingCoordinator = nil
				}

				self.deltaOnboardingCoordinator?.startOnboarding()
			}
		}.store(in: &subscriptions)
	}

	private func setupBarButtonItems() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Corona-Warn-App"), style: .plain, target: nil, action: nil)

		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
	}

	/// This method sets up a background fetch alert, and presents it, if needed.
	/// Check the `createBackgroundFetchAlert` method for more information.
	private func setupBackgroundFetchAlert() {
		guard let alert = createBackgroundFetchAlert(
			status: UIApplication.shared.backgroundRefreshStatus,
			inLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
			hasSeenAlertBefore: homeInteractor.store.hasSeenBackgroundFetchAlert,
			store: homeInteractor.store
			) else { return }

		self.present(
			alert,
			animated: true,
			completion: nil
		)
	}

	private func setupAccessibility() {
		navigationItem.leftBarButtonItem?.customView = UIImageView(image: navigationItem.leftBarButtonItem?.image)
		navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		navigationItem.leftBarButtonItem?.accessibilityTraits = .none
		navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
	}

	// MARK: Actions

	@IBAction private func infoButtonTapped() {
		delegate?.showRiskLegend()
	}

	// MARK: Misc
	@objc
	func refreshUIAfterResumingFromBackground() {
		homeInteractor.refreshTimerAfterResumingFromBackground()
		homeInteractor.updateTestResults()
	}

	// Called by HomeInteractor
	func setStateOfChildViewControllers() {
		delegate?.setExposureDetectionState(state: homeInteractor.state, activityState: homeInteractor.riskProvider.activityState)
	}

	func updateDetectionMode(
		_ detectionMode: DetectionMode
	) {
		homeInteractor.updateDetectionMode(detectionMode)

		reloadData(animatingDifferences: false)

		showRiskStatusLoweredAlertIfNeeded()
	}

	func showRiskStatusLoweredAlertIfNeeded() {
		guard store.shouldShowRiskStatusLoweredAlert else { return }

		let alert = UIAlertController(
			title: AppStrings.Home.riskStatusLoweredAlertTitle,
			message: AppStrings.Home.riskStatusLoweredAlertMessage,
			preferredStyle: .alert
		)

		let alertAction = UIAlertAction(
			title: AppStrings.Home.riskStatusLoweredAlertPrimaryButtonTitle,
			style: .default
		)
		alert.addAction(alertAction)

		present(alert, animated: true) { [weak self] in
			self?.store.shouldShowRiskStatusLoweredAlert = false
		}
	}

	func showExposureSubmissionWithoutResult() {
		showExposureSubmission()
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		delegate?.showExposureSubmission(with: result)
	}

	func showDiary() {
		delegate?.showDiary()
	}

	func showExposureNotificationSetting() {
		delegate?.showExposureNotificationSetting(enState: self.homeInteractor.state.enState)
	}

	func showExposureDetection() {
		delegate?.showExposureDetection(state: homeInteractor.state, activityState: homeInteractor.riskProvider.activityState)
	}

	func scrollToTop(animated: Bool) {
		collectionView.scrollToItem(
			at: IndexPath(item: 0, section: 0),
			at: .top,
			animated: animated
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
			showExposureSubmission(with: homeInteractor.testResult)
		case is HomeTestResultCollectionViewCell:
			showExposureSubmission(with: homeInteractor.testResult)
		case is RiskInactiveCollectionViewCell:
			showExposureDetection()
		case is RiskFailedCollectionViewCell:
			showExposureDetection()
		case is HomeDiaryCollectionViewCell:
			showDiary()
		case is RiskThankYouCollectionViewCell:
			return
		default:
			Log.info("Unknown cell type tapped.", log: .ui)
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
				delegate?.showInviteFriends()
			} else {
				delegate?.showWebPage(from: self, urlString: AppStrings.SafariView.targetURL)
			}
		case .settings:
			if row == 0 {
				delegate?.showAppInformation()
			} else {
				delegate?.showSettings(enState: self.homeInteractor.state.enState)
			}
		}
	}

	// MARK: Configuration

	func reloadData(animatingDifferences: Bool) {
		updateSections()
		applySnapshotFromSections(animatingDifferences: animatingDifferences)
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

		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isDirectionalLockEnabled = true
		collectionView.backgroundColor = .enaColor(for: .darkBackground)

		let cellTypes: [UICollectionViewCell.Type] = [
			ActivateCollectionViewCell.self,
			RiskLevelCollectionViewCell.self,
			InfoCollectionViewCell.self,
			HomeTestResultCollectionViewCell.self,
			RiskFailedCollectionViewCell.self,
			RiskInactiveCollectionViewCell.self,
			RiskFindingPositiveCollectionViewCell.self,
			RiskThankYouCollectionViewCell.self,
			InfoCollectionViewCell.self,
			HomeTestResultLoadingCell.self,
			HomeDiaryCollectionViewCell.self
		]

		collectionView.register(cellTypes: cellTypes)
	}

	private func configureDataSource() {
		dataSource = CollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { [unowned self] collectionView, indexPath, _ in
			let configurator = self.sections[indexPath.section].cellConfigurators[indexPath.row]
			let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
			cell.unhighlight()
			configurator.configureAny(cell: cell)
			return cell
		}
	}

	func applySnapshotFromSections(animatingDifferences: Bool = false) {
		var snapshot = DiffableDataSourceSnapshot<Section, AnyHashable>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems( section.cellConfigurators.map { $0.hashValue })
		}
		dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
	}

	func updateSections() {
		sections = homeInteractor.sections
	}

	func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
		return self.collectionView.cellForItem(at: indexPath)
	}
}

// MARK: - Update test state.

extension HomeViewController {
	func showTestResultScreen() {
		showExposureSubmission(with: homeInteractor.testResult)
	}

	func updateTestResultState() {
		homeInteractor.reloadActionSection()
		homeInteractor.updateTestResults()
	}
}

extension HomeViewController: HomeLayoutDelegate {
	func homeLayoutSection(for sectionIndex: Int) -> Section? {
		Section(rawValue: sectionIndex)
	}
}

extension HomeViewController {
	override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		let cell = collectionView.cellForItem(at: indexPath)
		switch cell {
		case is RiskThankYouCollectionViewCell: return false
		default: return true
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.highlight()
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.unhighlight()
	}

	override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showScreen(at: indexPath)
	}
}

extension HomeViewController: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeInteractor.updateExposureManagerState(state)
		reloadData(animatingDifferences: false)
	}
}

extension HomeViewController: ENStateHandlerUpdating {
	func updateEnState(_ enState: ENStateHandler.State) {
		homeInteractor.updateEnState(enState)
		reloadData(animatingDifferences: false)
	}
}

extension HomeViewController: NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (collectionView.adjustedContentInset.top + collectionView.contentOffset.y) / collectionView.contentInset.top
		return max(0, min(alpha, 1))
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
