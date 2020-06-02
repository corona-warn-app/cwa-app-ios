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
import SafariServices
import UIKit

protocol HomeViewControllerDelegate: AnyObject {
	func homeViewControllerStartExposureTransaction(_ controller: HomeViewController)
	func homeViewControllerUserDidRequestReset(_ controller: HomeViewController)
}

// swiftlint:disable:next type_body_length
final class HomeViewController: UIViewController {
	// MARK: Creating a Home View Controller

	init?(
		coder: NSCoder,
		exposureManager: ExposureManager,
		client: Client,
		store: Store,
		keyPackagesStore: DownloadedPackagesStore,
		delegate: HomeViewControllerDelegate
	) {
		self.client = client
		self.store = store
		self.keyPackagesStore = keyPackagesStore
		self.exposureManager = exposureManager
		self.delegate = delegate

		super.init(coder: coder)
		homeInteractor = HomeInteractor(
			homeViewController: self,
			store: store,
			state: .init(isLoading: false, summary: nil, exposureManager: .init())
		)

		exposureSubmissionService = ENAExposureSubmissionService(
			diagnosiskeyRetrieval: self.exposureManager,
			client: self.client,
			store: self.store
		)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	private var sections: [(section: Section, cellConfigurators: [CollectionViewCellConfiguratorAny])] = []

	private let keyPackagesStore: DownloadedPackagesStore
	private let exposureManager: ExposureManager
	private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>?
	private var collectionView: UICollectionView!
	private var homeLayout: HomeLayout!
	var homeInteractor: HomeInteractor!
	private let store: Store
	private let client: Client
	private var summaryNotificationObserver: NSObjectProtocol?
	private weak var exposureDetectionController: ExposureDetectionViewController?
	private weak var settingsController: SettingsViewController?
	private weak var notificationSettingsController: ExposureNotificationSettingViewController?
	private weak var delegate: HomeViewControllerDelegate?
	private var exposureSubmissionService: ExposureSubmissionService?
	private var testResult: TestResult?

	enum Section: Int {
		case actions
		case infos
		case settings
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		configureHierarchy()
		configureDataSource()
		updateSections()
		applySnapshotFromSections()
		configureUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateOwnUI()
		navigationItem.largeTitleDisplayMode = .never
		homeInteractor.developerMenuEnableIfAllowed()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(summaryNotificationObserver as Any, name: .didDetectExposureDetectionSummary, object: nil)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
				let image = UIImage(named: "navi_bar_icon")
				let leftItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
				leftItem.isEnabled = false
				self.navigationItem.leftBarButtonItem = leftItem
		}
	}

	// MARK: Actions

	@objc
	private func infoButtonTapped(_: UIButton) {
		let vc = RiskLegendTableViewController.initiate(for: .riskLegend)
		let naviController = UINavigationController(rootViewController: vc)
		present(naviController, animated: true, completion: nil)
	}

	// MARK: Misc

	// Called by HomeInteractor
	func setStateOfChildViewControllers(_ state: State, stateHandler: ENStateHandler) {
		settingsController?.stateHandler = stateHandler
		notificationSettingsController?.stateHandler = stateHandler
		let riskLevel = RiskLevel(riskScore: state.summary?.maximumRiskScore)
		let state = ExposureDetectionViewController.State(
			exposureManagerState: state.exposureManager,
			riskLevel: riskLevel,
			nextRefresh: nil,
			summary: state.summary
		)
		exposureDetectionController?.state = state
	}

	func showExposureSubmission(with result: TestResult? = nil) {
		guard let exposureSubmissionService = exposureSubmissionService else { return }
		present(
			AppStoryboard.exposureSubmission.initiateInitial { coder in
				ExposureSubmissionNavigationController(
					coder: coder,
					exposureSubmissionService: exposureSubmissionService,
					testResult: result
				)
			},
			animated: true
		)
	}

	func showDeveloperMenu() {
		let developerMenuController = AppStoryboard.developerMenu.initiateInitial()
		present(developerMenuController, animated: true, completion: nil)
	}

	func showInviteFriends() {
		let vc = FriendsInviteController.initiate(for: .inviteFriends)
		navigationController?.pushViewController(vc, animated: true)
	}

	// This method makes the exposure manager usable.
	private func enableExposureManagerIfNeeded() {
		func activate(then completion: @escaping () -> Void) {
			exposureManager.activate { error in
				if let error = error {
					logError(message: "Failed to activate: \(error)")
					return
				}
				completion()
			}
		}
		func enable() {
			exposureManager.enable { error in
				if let error = error {
					logError(message: "Failed to enable: \(error)")
					return
				}
			}
		}

		func enableIfNeeded() {
			guard exposureManager.preconditions().enabled else {
				enable()
				return
			}
		}

		let status = exposureManager.preconditions()

		guard status.authorized else {
			log(message: "User declined authorization")
			return
		}

		guard status.status == .active else {
			activate(then: enableIfNeeded)
			return
		}
		enableIfNeeded()
	}

	func showExposureNotificationSetting() {
		let storyboard = AppStoryboard.exposureNotificationSetting.instance
		let vc = storyboard.instantiateViewController(identifier: "ExposureNotificationSettingViewController") { coder in
			ExposureNotificationSettingViewController(
				coder: coder,
				stateHandler: self.homeInteractor.stateHandler,
				delegate: self
			)
		}
		notificationSettingsController = vc
		navigationController?.pushViewController(vc, animated: true)
	}

	func showSetting() {
		let storyboard = AppStoryboard.settings.instance
		let vc = storyboard.instantiateViewController(identifier: "SettingsViewController") { coder in
			SettingsViewController(
				coder: coder,
				store: self.store,
				stateHandler: self.homeInteractor.stateHandler,
				delegate: self
			)
		}
		settingsController = vc
		navigationController?.pushViewController(vc, animated: true)
	}

	func showExposureDetection() {
		let riskLevel = RiskLevel(riskScore: homeInteractor.state.summary?.maximumRiskScore)
		let state = ExposureDetectionViewController.State(
			exposureManagerState: homeInteractor.state.exposureManager,
			riskLevel: riskLevel,
			nextRefresh: nil, // TODO,
			summary: homeInteractor.state.summary
		)

		let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
			ExposureDetectionViewController(
				coder: coder,
				state: state,
				delegate: self
			)
		}
		exposureDetectionController = vc as? ExposureDetectionViewController
		present(vc, animated: true)
	}

	func showAppInformation() {
		navigationController?.pushViewController(
			AppStoryboard.appInformation.initiateInitial(),
			animated: true
		)
	}

	func showWebPage() {
		if let url = URL(string: AppStrings.SafariView.targetURL) {
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			config.barCollapsingEnabled = true

			let vc = SFSafariViewController(url: url, configuration: config)
			present(vc, animated: true)
		} else {
			let error = "\(AppStrings.SafariView.targetURL) is no valid URL"
			logError(message: error)
			fatalError(error)
		}
	}

	private func showScreen(at indexPath: IndexPath) {
		guard let section = Section(rawValue: indexPath.section) else { return }
		let row = indexPath.row
		switch section {
		case .actions:
			if row == 0 {
				showExposureNotificationSetting()
			} else if row == 1 {
				showExposureDetection()
			}
		case .infos:
			if row == 0 {
				showInviteFriends()
			} else {
				showWebPage()
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
		collectionView.reloadData()
	}

	func reloadCell(at indexPath: IndexPath) {
		settingsController?.stateHandler = homeInteractor.stateHandler
		notificationSettingsController?.stateHandler = homeInteractor.stateHandler
		guard let snapshot = dataSource?.snapshot() else { return }
		guard let cell = collectionView.cellForItem(at: indexPath) else { return }
		sections[indexPath.section].cellConfigurators[indexPath.item].configureAny(cell: cell)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}

	private func createLayout() -> UICollectionViewLayout {
		homeLayout = HomeLayout()
		homeLayout.delegate = self
		return homeLayout.collectionLayout()
	}

	private func configureHierarchy() {
		let safeLayoutGuide = view.safeAreaLayoutGuide

		view.backgroundColor = .systemGroupedBackground

		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
		collectionView.delegate = self
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isAccessibilityElement = false
		collectionView.shouldGroupAccessibilityChildren = true
		view.addSubview(collectionView)

		NSLayoutConstraint.activate(
			[
				collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
				collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
				collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
				collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)

		let cellTypes: [UICollectionViewCell.Type] = [ActivateCollectionViewCell.self, RiskCollectionViewCell.self, SubmitCollectionViewCell.self, InfoCollectionViewCell.self]
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
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(infoButtonTapped(_:)))
		
		let image = UIImage(named: "navi_bar_icon")
		let leftItem = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
		leftItem.isEnabled = false
		self.navigationItem.leftBarButtonItem = leftItem
	}
}

// MARK: - Update test state.

extension HomeViewController {

	func updateTestResultFor(_ cell: HomeTestResultCell, with configurator: HomeTestResultCellConfigurator) {
		self.exposureSubmissionService?.getTestResult { result in
			switch result {
			case .failure(let error):
				appLogger.log(message: "Could not update test state: \(error)", file: #file, line: #line, function: #function)
			case .success(let result):
				self.testResult = result
				configurator.configure(cell: cell)
			}
		}
	}

	func showTestResult() {
		showExposureSubmission(with: testResult)
	}
}

extension HomeViewController: HomeLayoutDelegate {
	func homeLayout(homeLayout _: HomeLayout, for sectionIndex: Int) -> Section? {
		Section(rawValue: sectionIndex)
	}
}

extension HomeViewController: UICollectionViewDelegate {
	func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showScreen(at: indexPath)
	}
}

extension HomeViewController: ExposureDetectionViewControllerDelegate {
	func exposureDetectionViewControllerStartTransaction(
		_: ExposureDetectionViewController
	) {
		delegate?.homeViewControllerStartExposureTransaction(self)
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
		updateOwnUI()
		homeInteractor.updateExposureState(state)
		exposureDetectionController?.updateUI()
		settingsController?.updateExposureState(state)
		notificationSettingsController?.updateExposureState(state)
	}

	private func updateOwnUI() {
		reloadData()
	}
}

// MARK: Working with the Delegate

extension HomeViewController {
	private func startExposureTransaction() {
		delegate?.homeViewControllerStartExposureTransaction(self)
	}
}
