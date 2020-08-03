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
	func showRiskLegend()
	func showExposureNotificationSetting(enState: ENStateHandler.State)
	func showExposureDetection(state: HomeInteractor.State, isRequestRiskRunning: Bool)
	func setExposureDetectionState(state: HomeInteractor.State, isRequestRiskRunning: Bool)
	func showExposureSubmission(with result: TestResult?)
	func showInviteFriends()
	func showWebPage(from viewController: UIViewController, urlString: String)
	func showAppInformation()
	func showSettings(enState: ENStateHandler.State)
	func addToEnStateUpdateList(_ anyObject: AnyObject?)
}

final class HomeViewController: UIViewController, RequiresAppDependencies {
	// MARK: Creating a Home View Controller
	init?(
		coder: NSCoder,
		delegate: HomeViewControllerDelegate,
		detectionMode: DetectionMode,
		exposureManagerState: ExposureManagerState,
		initialEnState: ENStateHandler.State,
		risk: Risk?,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.delegate = delegate
		//self.enState = initialEnState
		super.init(coder: coder)
		self.homeInteractor = HomeInteractor(
			homeViewController: self,
			state: .init(
				detectionMode: detectionMode,
				exposureManagerState: exposureManagerState,
				enState: initialEnState,
				risk: risk
			), exposureSubmissionService: exposureSubmissionService)
		navigationItem.largeTitleDisplayMode = .never
		delegate.addToEnStateUpdateList(homeInteractor)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	private var sections: HomeInteractor.SectionConfiguration = []
	private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>?
	private var collectionView: UICollectionView! { view as? UICollectionView }
	private var homeInteractor: HomeInteractor!

	private weak var delegate: HomeViewControllerDelegate?

	enum Section: Int {
		case actions
		case infos
		case settings
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBackgroundFetchAlert()
		configureCollectionView()
		configureDataSource()
		setupAccessibility()

		homeInteractor.buildSections()
		updateSections()
		applySnapshotFromSections()

		setStateOfChildViewControllers()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		homeInteractor.updateTestResults()
		homeInteractor.requestRisk(userInitiated: false)
		updateBackgroundColor()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard store.userNeedsToBeInformedAboutHowRiskDetectionWorks else {
			return
		}
		// TODO: Check whether or not we have to display some kind of different alert (eg. the forced update alert).
		let alert = UIAlertController.localizedHowRiskDetectionWorksAlertController(
			maximumNumberOfDays: TracingStatusHistory.maxStoredDays
		)
		present(alert, animated: true) {
			self.store.userNeedsToBeInformedAboutHowRiskDetectionWorks = false
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBackgroundColor()
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

	// Called by HomeInteractor
	func setStateOfChildViewControllers() {
		delegate?.setExposureDetectionState(state: homeInteractor.state, isRequestRiskRunning: homeInteractor.riskProvider.isLoading)
	}

	func updateState(detectionMode: DetectionMode, exposureManagerState: ExposureManagerState, risk: Risk?) {
		homeInteractor.state.detectionMode = detectionMode
		homeInteractor.state.exposureManagerState = exposureManagerState
		homeInteractor.state.risk = risk

		reloadData(animatingDifferences: false)
	}

	func showExposureSubmissionWithoutResult() {
		showExposureSubmission()
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		delegate?.showExposureSubmission(with: result)
	}

	func showExposureNotificationSetting() {
		delegate?.showExposureNotificationSetting(enState: self.homeInteractor.state.enState)
	}

	func showExposureDetection() {
		delegate?.showExposureDetection(state: homeInteractor.state, isRequestRiskRunning: homeInteractor.riskProvider.isLoading)
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
		dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { [unowned self] collectionView, indexPath, _ in
			let configurator = self.sections[indexPath.section].cellConfigurators[indexPath.row]
			let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
			cell.unhighlight()
			configurator.configureAny(cell: cell)
			return cell
		}
	}

	func applySnapshotFromSections(animatingDifferences: Bool = false) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems( section.cellConfigurators.map { $0.hashValue })
		}
		dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
	}

	func updateSections() {
		sections = homeInteractor.sections
	}

	private func updateBackgroundColor() {
		if traitCollection.userInterfaceStyle == .light {
			collectionView.backgroundColor = .enaColor(for: .background)
		} else {
			collectionView.backgroundColor = .enaColor(for: .separator)
		}
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

extension HomeViewController: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeInteractor.state.exposureManagerState = state
		reloadData(animatingDifferences: false)
	}
}

extension HomeViewController: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeInteractor.state.enState = state
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
