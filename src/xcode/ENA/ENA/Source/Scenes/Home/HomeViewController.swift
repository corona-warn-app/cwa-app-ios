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
    
    init?(
        coder: NSCoder,
        exposureManager: ExposureManager,
        client: Client,
        store: Store,
        signedPayloadStore: SignedPayloadStore
    ) {
        self.client = client
        self.store = store
        self.signedPayloadStore = signedPayloadStore
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
    private let signedPayloadStore: SignedPayloadStore

    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
    private var collectionView: UICollectionView!
    private var tableView: UITableView!

    private var collectionHeightConstraint: NSLayoutConstraint?
    private var tableHeightConstraint: NSLayoutConstraint?

	private var homeLayout: HomeLayout!
    private var homeInteractor: HomeInteractor!
    private var cellConfigurators: [CollectionViewCellConfiguratorAny] = []
    private let store: Store
    private let client: Client

	private var summaryNotificationObserver: NSObjectProtocol?

    enum Section: Int {
        case actions
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareData()
        configureHierarchy()
        configureDataSource()
        configureUI()
		tableView.reloadData()
		resizeDataViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        homeInteractor.developerMenuEnableIfAllowed()
		
		summaryNotificationObserver = NotificationCenter.default.addObserver(forName: .didDetectExposureDetectionSummary, object: nil, queue: nil) { notification in
			// Temporary handling of exposure detection summary notification until implemented in transaction flow
			if let userInfo = notification.userInfo as? [String: Any], let summary = userInfo["summary"] as? ENExposureDetectionSummary {
				log(message: "got summary: \(summary.description)")
				self.homeInteractor.detectionSummary = summary
				self.prepareData()
				self.reloadData()
			}
		}
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(summaryNotificationObserver, name: .didDetectExposureDetectionSummary, object: nil)
	}
	
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        resizeDataViews()
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
                self.navigationController?.pushViewController(vc, animated: true)
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
        let developerMenuController = AppStoryboard.developerMenu.initiateInitial()
        present(developerMenuController, animated: true, completion: nil)
    }

    func showInviteFriends() {
        let vc = FriendsInviteController.initiate(for: .inviteFriends)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showExposureDetection() {
        let vc = AppStoryboard.exposureDetection.initiateInitial { coder in
            ExposureDetectionViewController(
                coder: coder,
                store: self.store,
                client: self.client,
                signedPayloadStore: self.signedPayloadStore
            )
        }
        present(vc, animated: true)
    }

    func showAppInformation() {
        navigationController?.pushViewController(
            AppStoryboard.appInformation.initiateInitial(),
            animated: true
        )
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
        }
    }

    // MARK: Configuration

    func prepareData() {
        cellConfigurators = homeInteractor.cellConfigurators()
    }

    func reloadData() {
        collectionView.reloadData()
    }

    private func resizeDataViews() {
        tableView.invalidateIntrinsicContentSize()
        view.layoutIfNeeded()
    
        let collectionHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let tableHeight = tableView.contentSize.height
        
        collectionHeightConstraint?.isActive = false
        tableHeightConstraint?.isActive = false

        collectionHeightConstraint?.constant = collectionHeight
        tableHeightConstraint?.constant = tableHeight

        collectionHeightConstraint?.isActive = true
        tableHeightConstraint?.isActive = true

        view.setNeedsLayout()
    }

    private func createLayout() -> UICollectionViewLayout {
        homeLayout = HomeLayout()
        homeLayout.delegate = self
        return homeLayout.collectionLayout()
    }

	private func createCollectionView() {
		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isScrollEnabled = false
		collectionView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		collectionView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
	}
	
	private func createTableView() {
		tableView = UITableView(frame: view.bounds, style: .grouped)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .systemGroupedBackground
		tableView.backgroundView = nil
		tableView.isScrollEnabled = false
		tableView.bounces = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 88
	}
	
    private func configureHierarchy() {
        let safeLayoutGuide = view.safeAreaLayoutGuide

		view.backgroundColor = .systemGroupedBackground
			
		createCollectionView()
		createTableView()
				
		collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 88)
		collectionHeightConstraint?.priority = .defaultHigh
		collectionHeightConstraint?.isActive = true
		tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 88)
		tableHeightConstraint?.priority = .defaultHigh
		tableHeightConstraint?.isActive = true
		
		let stackView = UIStackView(arrangedSubviews: [collectionView, tableView])
		stackView.backgroundColor = UIColor.clear
		stackView.alignment = .fill
		stackView.axis = .vertical
		stackView.distribution = .equalSpacing
		stackView.spacing = 0.0
		stackView.translatesAutoresizingMaskIntoConstraints = false

		let scrollView = UIScrollView()
		scrollView.backgroundColor = UIColor.clear
		scrollView.alwaysBounceVertical = true
		scrollView.isScrollEnabled = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		scrollView.addSubview(stackView)
		view.addSubview(scrollView)

        NSLayoutConstraint.activate(
            [
				scrollView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
				scrollView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
				scrollView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
				scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
				stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
				stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
				stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
				stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
			]
        )

		collectionView.register(cellTypes: cellConfigurators.map { $0.viewAnyType })
        let nib6 = UINib(nibName: HomeFooterSupplementaryView.reusableViewIdentifier, bundle: nil)
        collectionView.register(nib6, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier)

		let infoNib = UINib(nibName: InfoTableViewCell.stringName(), bundle: nil)
		tableView.register(infoNib, forCellReuseIdentifier: InfoTableViewCell.stringName())
		tableView.reloadData()
    }

    private func configureDataSource() {
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

