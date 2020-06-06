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

// swiftlint:disable:next type_body_length
final class HomeViewController: UIViewController, RequiresAppDependencies {
	// MARK: Creating a Home View Controller

	init?(
		coder: NSCoder,
		exposureManager: ExposureManager,
		delegate: HomeViewControllerDelegate,
		initialEnState: ENStateHandler.State
	) {
		self.exposureManager = exposureManager
		self.delegate = delegate
		self.enState = initialEnState
		super.init(coder: coder)
		addToUpdatingSetIfNeeded(homeInteractor)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	deinit {
		enStateUpdatingSet.removeAllObjects()
	}
	// MARK: Properties

	private var sections: HomeInteractor.SectionConfiguration = []
	private let exposureManager: ExposureManager
	private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
	private var collectionView: UICollectionView!
	private var enState: ENStateHandler.State
	lazy var homeInteractor: HomeInteractor = {
		HomeInteractor(
			homeViewController: self,
			state: .init(
				isLoading: false,
				exposureManager: .init(),
                risk: risk
			),
			exposureSubmissionService: exposureSubmissionService,
			initialEnState: self.enState
		)
	}()
	private weak var exposureDetectionController: ExposureDetectionViewController?
	private weak var settingsController: SettingsViewController?
	private weak var notificationSettingsController: ExposureNotificationSettingViewController?
	private weak var delegate: HomeViewControllerDelegate?
	private lazy var exposureSubmissionService: ExposureSubmissionService = {
		ENAExposureSubmissionService(
			diagnosiskeyRetrieval: self.exposureManager,
			client: self.client,
			store: self.store
		)
	}()
	private var enStateUpdatingSet = NSHashTable<AnyObject>.weakObjects()

	private var risk: Risk?
	private let riskConsumer = RiskConsumer()

	enum Section: Int {
		case actions
		case infos
		case settings
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.risk = risk
			self?.updateOwnUI()
		}

		configureHierarchy()
		configureDataSource()
		updateSections()
		applySnapshotFromSections()
		configureUI()
		homeInteractor.updateTestResults()
		setupAccessibility()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateOwnUI()
		navigationItem.largeTitleDisplayMode = .never
		homeInteractor.developerMenuEnableIfAllowed()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
			let image = UIImage(named: "Corona-Warn-App")
			let leftItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
			leftItem.isEnabled = false
			self.navigationItem.leftBarButtonItem = leftItem
		}
	}

	private func setupAccessibility() {
		self.navigationItem.leftBarButtonItem?.isAccessibilityElement = true
		self.navigationItem.leftBarButtonItem?.accessibilityTraits = .staticText
		self.navigationItem.leftBarButtonItem?.accessibilityLabel = AppStrings.Home.leftBarButtonDescription

		self.navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		self.navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
	}

	// MARK: Actions

	@objc
	private func infoButtonTapped() {
		present(
			AppStoryboard.riskLegend.initiateInitial(),
			animated: true,
			completion: nil
		)
	}

	// MARK: Misc

	// Called by HomeInteractor
	func setStateOfChildViewControllers(_ state: State) {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: state.exposureManager,
			risk: risk,
			nextRefresh: nil
		)
		exposureDetectionController?.state = state
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
					homeViewController: self,
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
					initialEnState: self.enState,
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
				initialEnState: self.enState,
				delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
		settingsController = vc
		navigationController?.pushViewController(vc, animated: true)
	}

	func showExposureDetection() {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: homeInteractor.state.exposureManager,
			risk: risk,
			nextRefresh: nil
		)

		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				delegate: self
			)
		}
		addToUpdatingSetIfNeeded(vc)
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
			showExposureSubmission(with: homeInteractor.testResult)
		case is HomeTestResultCell:
			showExposureSubmission(with: homeInteractor.testResult)
		case is SubmitCollectionViewCell:
			showExposureSubmission()
		case is RiskThankYouCollectionViewCell:
			return
		default:
			appLogger.log(message: "Unknown cell type tapped.", file: #file, line: #line, function: #function)
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

	private func configureHierarchy() {
		let safeLayoutGuide = view.safeAreaLayoutGuide
		view.backgroundColor = .systemGroupedBackground
		collectionView = UICollectionView(
			frame: view.bounds,
			collectionViewLayout: UICollectionViewLayout.homeLayout(delegate: self)
		)
		collectionView.delegate = self
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isAccessibilityElement = false
		collectionView.shouldGroupAccessibilityChildren = true
		collectionView.alwaysBounceVertical = true
		view.addSubview(collectionView)

		NSLayoutConstraint.activate(
			[
				collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
				collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
				collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
				collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)

		let cellTypes: [UICollectionViewCell.Type] = [
			ActivateCollectionViewCell.self,
			RiskLevelCollectionViewCell.self,
			SubmitCollectionViewCell.self,
			InfoCollectionViewCell.self,
			HomeTestResultCell.self,
			RiskInactiveCollectionViewCell.self,
			RiskFindingPositiveCollectionViewCell.self,
			RiskThankYouCollectionViewCell.self,
			InfoCollectionViewCell.self
		]

		collectionView.register(cellTypes: cellTypes)
		let nib6 = UINib(nibName: HomeFooterSupplementaryView.reusableViewIdentifier, bundle: nil)
		collectionView.register(nib6, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier)
	}

	private func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { [unowned self] collectionView, indexPath, _ in
			let configurator = self.sections[indexPath.section].cellConfigurators[indexPath.row]
			let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
			configurator.configureAny(cell: cell)
			return cell
		}
		dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
			let identifier = HomeFooterSupplementaryView.reusableViewIdentifier
			guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: identifier,
				for: indexPath
			) as? HomeFooterSupplementaryView else {
				fatalError("Cannot create new supplementary")
			}
			supplementaryView.configure()
			return supplementaryView
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

	private func configureUI() {
		collectionView.backgroundColor = .systemGroupedBackground
		let infoImage = UIImage(systemName: "info.circle")
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: infoImage,
			style: .plain,
			target: self,
			action: #selector(infoButtonTapped)
		)
		let image = UIImage(named: "Corona-Warn-App")
		let leftItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
		leftItem.isEnabled = false
		self.navigationItem.leftBarButtonItem = leftItem
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
	func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showScreen(at: indexPath)
	}
}

extension HomeViewController: ExposureDetectionViewControllerDelegate {
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
		updateOwnUI()
		exposureDetectionController?.updateUI()
		settingsController?.updateExposureState(state)
	}

	private func updateOwnUI() {
		reloadData()
	}
}

extension  HomeViewController: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
		updateAllState(state)
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
