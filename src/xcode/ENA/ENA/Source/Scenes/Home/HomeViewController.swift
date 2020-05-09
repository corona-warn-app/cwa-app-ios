//
//  HomeViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

final class HomeViewController: UIViewController {
    // MARK: Creating a Home View Controller
    init?(coder: NSCoder, exposureManager: ExposureManager) {
        self.exposureManager = exposureManager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has intentionally not been implemented")
    }
    
    // MARK: Properties
    @IBOutlet var topContainerView: UIView!
    private let exposureManager: ExposureManager
    var summary: ENExposureDetectionSummary?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    private var collectionView: UICollectionView! = nil
    private var homeLayout: HomeLayout!
    private var homeInteractor: HomeInteractor!
    private lazy var client: Client = {
        let fileManager = FileManager()
        let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentDir.appendingPathComponent("keys", isDirectory: false).appendingPathExtension("proto")
        return MockClient(submittedKeysFileURL: fileUrl)
    }()
    private var cellConfigurators: [CollectionViewCellConfiguratorAny] = []
    private lazy var developerMenu: DMDeveloperMenu = {
        DMDeveloperMenu(presentingViewController: self, client: client)
    }()
    
    // MARK: Types
    enum Section: Int {
        // swiftlint:disable explicit_enum_raw_value
        case actions
        case infos
        case settings
        // swiftlint:enable explicit_enum_raw_value
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        homeInteractor = HomeInteractor(homeViewController: self)
        prepareData()
        configureHierarchy()
        configureDataSource()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        developerMenu.enableIfAllowed()
    }
    
    // MARK: Actions
    @IBAction private func infoButtonTapped(_ sender: UIButton) {
        log(message: "")
    }
    
    // MARK: Misc
    func showSubmitResult() {
        let vc = ExposureSubmissionViewController.initiate(for: .exposureSubmission)
        vc.exposureSubmissionService = ExposureSubmissionServiceImpl(client: client)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }

    func showExposureNotificationSetting() {
        
                
        let enStoryBoard = AppStoryboard.exposureNotificationSetting.instance
        
        //TODO: This is a workaround approach, create exposure manager everytime.
        let manager = ExposureManager()
        
        manager.activate { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                switch error {
                case .exposureNotificationRequired:
                    log(message: "Encourage the user to consider enabling Exposure Notifications.", level: .warning)
                case .exposureNotificationAuthorization:
                    log(message: "Encourage the user to authorize this application", level: .warning)
                }
            } else if let error = error {
                logError(message: error.localizedDescription)
            } else {
                let vc = enStoryBoard.instantiateViewController(identifier: "ExposureNotificationSettingViewController", creator: { coder in
                    return ExposureNotificationSettingViewController(coder: coder, manager: manager)
                }
                )
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    func showSetting() {
        let vc = SettingsViewController.initiate(for: .settings)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }

    func showDeveloperMenu() {
        let developerMenuController = AppStoryboard.developerMenu.initiateInitial()
        present(developerMenuController, animated: true, completion: nil)
    }

    func showInviteFriends() {
        let vc = FriendsInviteController.initiate(for: .inviteFriends)
        let naviController = UINavigationController(rootViewController: vc)
        self.present(naviController, animated: true, completion: nil)
    }

    func showExposureDetection() {
        // IMPORTANT:
        // In pull request #98 (https://github.com/corona-warn-app/cwa-app-ios/pull/98) we had to remove code
        // that used the already injected `ExposureManager` and did the following:
        //
        // - The manager was activated.
        // - Some basic error handling was performed – specifically exposureNotificationRequired and
        //   exposureNotificationAuthorization were handled by just logging a warning.
        // - The activated manager was injected into `ExposureDetectionViewController` by setting a property on it.
        //
        // We had to temporarily remove this code because it caused an error (invalid use of API - detection already running).
        // This error also happens in Apple's sample code and does not happen if ExposureManager is created on demand for
        // every exposure detection request. There are other situations where this error does not happen like when the internal
        // state of `ENManager` is mutated before kicking of an exposure detection. Our current workaround is to simply
        // create a new instance of `ExposureManager` (and thus of `ENManager`) for each exposure detection request.

        let exposureDetectionViewController = ExposureDetectionViewController.initiate(for: .exposureDetection)
        exposureDetectionViewController.delegate = self
        exposureDetectionViewController.client = self.client
        present(exposureDetectionViewController, animated: true, completion: nil)
    }

    func showAppInformation() {
        let vc = AppInformationViewController.initiate(for: .appInformation)
        let naviController = UINavigationController(rootViewController: vc)
        self.present(naviController, animated: true, completion: nil)
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
            } else {
                showSubmitResult()
            }
        case .infos:
            if row == 0 {
                showInviteFriends()
            } else {
                showAppInformation()
            }
        case .settings:
            showSetting()
        }
    }

    // MARK: Configuration
    private func prepareData() {
        cellConfigurators = homeInteractor.cellConfigurators()
    }

    private func createLayout() -> UICollectionViewLayout {
        homeLayout = HomeLayout()
        homeLayout.delegate = self
        return homeLayout.collectionLayout()
    }

    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        let safeLayoutGuide = view.safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
                collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        collectionView.register(cellTypes: cellConfigurators.map { $0.viewAnyType })
        let nib6 = UINib(nibName: HomeFooterSupplementaryView.reusableViewIdentifier, bundle: nil)
        collectionView.register(nib6, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            let configurator = self.cellConfigurators[identifier]
            let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
            configurator.configureAny(cell: cell)
            return cell
        }
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier, for: indexPath) as? HomeFooterSupplementaryView else {
                let error = "Cannot create new supplementary"
                logError(message: error)
                fatalError(error)
            }
            supplementaryView.configure()
            return supplementaryView
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.actions])
        snapshot.appendItems(Array(0...2))
        snapshot.appendSections([.infos])
        snapshot.appendItems(Array(3...4))
        snapshot.appendSections([.settings])
        snapshot.appendItems([5])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureUI () {
        collectionView.backgroundColor = .systemGroupedBackground
        topContainerView.backgroundColor = .systemBackground
    }
}

extension HomeViewController: HomeLayoutDelegate {
    func homeLayout(homeLayout: HomeLayout, for sectionIndex: Int) -> Section? {
        Section(rawValue: sectionIndex)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showScreen(at: indexPath)
    }
}

extension HomeViewController: ExposureDetectionViewControllerDelegate {
    func exposureDetectionViewController(_ controller: ExposureDetectionViewController, didReceiveSummary summary: ENExposureDetectionSummary) {
        log(message: "got summary: \(summary.description)")
        self.summary = summary
        collectionView.reloadData()
    }
}
