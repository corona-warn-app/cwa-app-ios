//
//  HomeViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var topContainerView: UIView!
    
    enum Section: Int {
        case main
        case info
        case settings
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    private var collectionView: UICollectionView! = nil
    private var homeLayout: HomeLayout!
    private var homeInteractor: HomeInteractor = HomeInteractor()
    
    private var cellConfigurators: [CollectionViewCellConfiguratorAny] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareData()
        configureHierarchy()
        configureDataSource()
        configureUI()
    }
    
    // MARK: Actions
    
    @IBAction private func infoButtonTapped(_ sender: UIButton) {
        print(#function)
    }
    
    private func showSubmitResult() {
        let vc = SelfExposureViewController.initiate(for: .selfExposure)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }
    
    private func showExposureNotifcationSetting() {
        let vc = ExposureNotificationSettingViewController.initiate(for: .exposureNotificationSetting)
        present(vc, animated: true, completion: nil)
    }
    
    private func showSetting() {
        let vc = SettingsViewController.initiate(for: .settings)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }

    private func showDeveloperMenu() {
        let developerMenuController = AppStoryboard.developerMenu.initiateInitial()
        present(developerMenuController, animated: true, completion: nil)
    }
    
    private func showScreen(at indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        let row = indexPath.row
        switch section {
        case .main:
            if row == 0 {
                showExposureNotifcationSetting()
            } else if row == 1 {
                // show risk page
            } else {
                showSubmitResult()
            }
        case .info:
            if row == 0 {
                // show share page
            } else {
                // show page about COVID-19
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
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeFooterSupplementaryView.reusableViewIdentifier, for: indexPath) as? HomeFooterSupplementaryView else { fatalError("Cannot create new supplementary") }
            supplementaryView.configure()
            return supplementaryView
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0...2))
        snapshot.appendSections([.info])
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
