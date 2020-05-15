//
//  HomeViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: Creating a Home View Controller

    init?(coder: NSCoder, exposureManager: ExposureManager, client: Client, store: Store) {
        self.client = client
        self.store = store
        super.init(coder: coder)
        homeInteractor = HomeInteractor(
            homeViewController: self,
            exposureManager: exposureManager,
            client: client,
            store: store
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has intentionally not been implemented")
    }

    // MARK: Properties
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
    private var collectionView: UICollectionView!
    private var homeLayout: HomeLayout!
    private var homeInteractor: HomeInteractor!
    private var cellConfigurators: [CollectionViewCellConfiguratorAny] = []
    private let store: Store
    private let client: Client

    enum Section: Int {
        // swiftlint:disable:next explicit_enum_raw_value
        case actions
        // swiftlint:disable:next explicit_enum_raw_value
        case infos
        // swiftlint:disable:next explicit_enum_raw_value
        case settings
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        configureHierarchy()
        configureDataSource()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeInteractor.developerMenuEnableIfAllowed()
    }

    // MARK: Actions
    @objc
    private func infoButtonTapped(_ sender: UIButton) {
        let vc = RiskLegendTableViewController.initiate(for: .riskLegend)
        let naviController = UINavigationController(rootViewController: vc)
        self.present(naviController, animated: true, completion: nil)
    }

    // MARK: Misc
    func showSubmitResult() {
        // swiftlint:disable:next unowned_variable_capture
        let vc = ExposureSubmissionViewController.initiate(for: .exposureSubmission) { [unowned self] coder in
            let service = ENAExposureSubmissionService(manager: ENAExposureManager(), client: self.client)
            return ExposureSubmissionViewController(coder: coder, exposureSubmissionService: service)
        }
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }

    func showExposureNotificationSetting() {

        let manager = ENAExposureManager()
        manager.activate { [weak self] error in
            guard let self = self else { return }
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

                let storyboard = AppStoryboard.exposureNotificationSetting.instance
                let vc = storyboard.instantiateViewController(identifier: "ExposureNotificationSettingViewController", creator: { coder in
                    ExposureNotificationSettingViewController(coder: coder, manager: manager)
                }
                )
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    func showSetting() {
        /*let vc = SettingsViewController.initiate(for: .settings)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)*/

        let manager = ENAExposureManager()
        manager.activate { [weak self] error in
            guard let self = self else { return }
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

                let storyboard = AppStoryboard.settings.instance
                let vc = storyboard.instantiateViewController(identifier: "SettingsViewController", creator: { coder in
                    SettingsViewController(coder: coder, manager: manager, store: self.store)
                }
                )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func showDeveloperMenu() {
        guard let developerMenuController = AppStoryboard.developerMenu.initiateInitial() else { return }
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

        let exposureDetectionViewController = ExposureDetectionViewController.initiate(for: .exposureDetection) { coder in
            ExposureDetectionViewController(coder: coder, client: self.client, store: self.store)
        }
        exposureDetectionViewController.delegate = homeInteractor
        present(exposureDetectionViewController, animated: true, completion: nil)
    }

    func showAppInformation() {
        let vc = AppInformationViewController.initiate(for: .appInformation)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
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

    func prepareData() {
        cellConfigurators = homeInteractor.cellConfigurators()
    }

    func reloadData() {
        collectionView.reloadData()
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
                collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        collectionView.register(cellTypes: cellConfigurators.map { $0.viewAnyType })
        let nib6 = UINib(nibName: HomeFooterSupplementaryView.reusableViewIdentifier, bundle: nil)
        collectionView.register(nib6, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier)
    }

    private func configureDataSource() {
        // swiftlint:disable:next unowned_variable_capture
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) { [unowned self] collectionView, indexPath, identifier in
            let configurator = self.cellConfigurators[identifier]
            let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
            configurator.configureAny(cell: cell)
            return cell
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
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
        title = "Corona-Warn-App"
        collectionView.backgroundColor = .systemGroupedBackground
        let infoImage = UIImage(systemName: "info.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(infoButtonTapped(_:)))
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
