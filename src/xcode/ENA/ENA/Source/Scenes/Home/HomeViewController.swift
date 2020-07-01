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
	func showSettings(enState: ENStateHandler.State)
	func showInviteFriends()
	func showExposureNotificationSetting(enState: ENStateHandler.State)
	func showAppInformation()
	func showWebPage(from viewController: UIViewController)
	func addToUpdatingSetIfNeeded(_ anyObject: AnyObject?)
}

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
		//self.enState = initialEnState
		super.init(coder: coder)
		self.homeInteractor = HomeInteractor(
			homeViewController: self,
			state: .init(
				detectionMode: detectionMode,
				exposureManagerState: exposureManagerState,
				enState: initialEnState,
				risk: risk
			))
		navigationItem.largeTitleDisplayMode = .never
		delegate.addToUpdatingSetIfNeeded(homeInteractor)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	private var sections: HomeInteractor.SectionConfiguration = []
	private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
	private var collectionView: UICollectionView! { view as? UICollectionView }
	private var homeInteractor: HomeInteractor!

	private weak var exposureDetectionController: ExposureDetectionViewController?
	private weak var settingsController: SettingsViewController?

	private weak var delegate: HomeViewControllerDelegate?

	enum Section: Int {
		case actions
		case infos
		case settings
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
		homeInteractor.updateTestResults()
		homeInteractor.requestRisk(userInitiated: false)
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
		navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
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

	// Called by HomeInteractor
	func setStateOfChildViewControllers() {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: homeInteractor.state.exposureManagerState,
			detectionMode: homeInteractor.state.detectionMode,
			isLoading: homeInteractor.isRequestRiskRunning,
			risk: homeInteractor.state.risk
		)
		exposureDetectionController?.state = state
	}

	func updateState(detectionMode: DetectionMode, exposureManagerState: ExposureManagerState, risk: Risk?) {
		homeInteractor.state.detectionMode = detectionMode
		homeInteractor.state.exposureManagerState = exposureManagerState
		homeInteractor.state.risk = risk
	}

	func showExposureSubmissionWithoutResult() {
		showExposureSubmission()
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		present(
			AppStoryboard.exposureSubmission.initiateInitial { coder in
				ExposureSubmissionNavigationController(
					coder: coder,
					exposureSubmissionService: self.homeInteractor.exposureSubmissionService,
					submissionDelegate: self,
					testResult: result
				)
			},
			animated: true
		)
	}

	func showExposureNotificationSetting() {
		delegate?.showExposureNotificationSetting(enState: self.homeInteractor.state.enState)
	}

	func showExposureDetection() {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: homeInteractor.state.exposureManagerState,
			detectionMode: homeInteractor.state.detectionMode,
			isLoading: homeInteractor.isRequestRiskRunning,
			risk: homeInteractor.state.risk
		)
		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				delegate: self
			)
		}
//		delegate?.addToUpdatingSetIfNeeded(vc)
		exposureDetectionController = vc as? ExposureDetectionViewController
		present(vc, animated: true)
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
				delegate?.showWebPage(from: self)
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
		sections = homeInteractor.sections
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

extension HomeViewController: ExposureDetectionViewControllerDelegate {
	func didStartLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		homeInteractor.updateAndReloadRiskLoading(isRequestRiskRunning: true)
	}

	func didFinishLoading(exposureDetectionViewController: ExposureDetectionViewController) {
		homeInteractor.updateAndReloadRiskLoading(isRequestRiskRunning: false)
	}

	func exposureDetectionViewController(
		_: ExposureDetectionViewController,
		setExposureManagerEnabled enabled: Bool,
		completionHandler completion: @escaping (ExposureNotificationError?) -> Void
	) {
		setExposureManagerEnabled(enabled, then: completion)
	}
}

private extension HomeViewController { // TODO: Remove
	func setExposureManagerEnabled(_ enabled: Bool, then completion: @escaping (ExposureNotificationError?) -> Void) {
		if enabled {
			homeInteractor.exposureManager.enable(completion: completion)
		} else {
			homeInteractor.exposureManager.disable(completion: completion)
		}
	}
}

extension HomeViewController: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		homeInteractor.state.exposureManagerState = state
		updateOwnUI()
		exposureDetectionController?.updateUI() // TODO: Move to Coordinator
	}

	private func updateOwnUI() {
		reloadData()
	}
}

extension HomeViewController: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		homeInteractor.state.enState = state
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

