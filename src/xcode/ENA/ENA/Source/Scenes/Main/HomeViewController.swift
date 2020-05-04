//
//  HomeViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    enum Section: Int {
        case main
        case info
        case settings
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Cards"
        configureHierarchy()
        configureDataSource()
    }
    
    // MARK: Actions
    
    func showSubmitResult() {
        let vc = SelfExposureViewController.initiate(for: .selfExposure)
        let naviController = UINavigationController(rootViewController: vc)
        present(naviController, animated: true, completion: nil)
    }
    
    func showExposureNotifcationSettingBtn() {
        let vc = ExposureNotificationSettingViewController.initiate(for: .exposureNotificationSetting)
        present(vc, animated: true, completion: nil)
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
    
    // MARK: Configuration
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        let safeLayoutGuide = view.safeAreaLayoutGuide
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
        ])
        
        collectionView.backgroundColor = .systemGroupedBackground
        let nib1 = UINib(nibName: ActivateCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib1, forCellWithReuseIdentifier: ActivateCollectionViewCell.reuseIdentifier)
        let nib2 = UINib(nibName: ActionCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib2, forCellWithReuseIdentifier: ActionCollectionViewCell.reuseIdentifier)
        let nib3 = UINib(nibName: SubmitCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib3, forCellWithReuseIdentifier: SubmitCollectionViewCell.reuseIdentifier)
        let nib4 = UINib(nibName: InfoCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib4, forCellWithReuseIdentifier: InfoCollectionViewCell.reuseIdentifier)
        
        let nib5 = UINib(nibName: SettingsCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib5, forCellWithReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier)
        
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: "HEADER", withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)

    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            let c: UICollectionViewCell
            if identifier == 1 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivateCollectionViewCell.reuseIdentifier, for: indexPath) as? ActivateCollectionViewCell else { fatalError("Cannot create the cell") }
                // cell.titleLabel.text = "Active"
                c = cell
            } else if identifier == 2 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionCollectionViewCell.reuseIdentifier, for: indexPath) as? ActionCollectionViewCell else { fatalError("Cannot create the cell") }
               // cell.titleLabel.text = "Action "
                c = cell
            } else if identifier == 3 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubmitCollectionViewCell.reuseIdentifier, for: indexPath) as? SubmitCollectionViewCell else { fatalError("Cannot create the cell") }
               // cell.titleLabel.text = "Submit"
                c = cell
            } else if identifier == 4 || identifier == 5 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCollectionViewCell.reuseIdentifier, for: indexPath) as? InfoCollectionViewCell else { fatalError("Cannot create the cell") }
               // cell.titleLabel.text = "Submit"
                c = cell
            } else if identifier == 6 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as? SettingsCollectionViewCell else { fatalError("Cannot create the cell") }
               // cell.titleLabel.text = "Submit"
                c = cell
            } else {
                fatalError()
            }
            
            return c
        }
        dataSource.supplementaryViewProvider = { (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath) -> UICollectionReusableView? in
            
            // Get a supplementary view of the desired kind.
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier,
                for: indexPath) as? TitleSupplementaryView else { fatalError("Cannot create new supplementary") }

            // Populate the view with our section's description.
            print(indexPath)
            supplementaryView.label.text = "da"
            supplementaryView.backgroundColor = .lightGray
            supplementaryView.layer.borderColor = UIColor.black.cgColor
            supplementaryView.layer.borderWidth = 1.0

            // Return the view.
            return supplementaryView
            
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(1...3))
        snapshot.appendSections([.info])
        snapshot.appendItems(Array(4...5))
        snapshot.appendSections([.settings])
        snapshot.appendItems([6])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension HomeViewController {
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section = self.layoutSection(for: sectionKind, layoutEnvironment: layoutEnvironment)
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 32.0
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "HEADER", alignment: .top)
        header.zIndex = 2
        header.pinToVisibleBounds = true
        config.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        layout.register(SectionSystemBackgroundDecorationView.self, forDecorationViewOfKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        return layout
    }
    
    private func layoutSection(for section: Section, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch section {
        case .main:
            return mainSection()
        case .info:
            return infoSection()
        case .settings:
            return settingsSection()
        }
    }
    
    private func mainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0/5.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0/2.0))
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let itemSize3 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0/2.0))
        let item3 = NSCollectionLayoutItem(layoutSize: itemSize3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item, item2, item3])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        let insets: CGFloat = 16.0
        section.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)
        
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        section.decorationItems = [sectionBackgroundDecoration]
        
        return section
    }
    
    private func infoSection() -> NSCollectionLayoutSection {
        
        let itemSize1 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0/2.0))
        let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
        
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0/2.0))
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item1, item2])
        group.interItemSpacing = .fixed(4)
        
        let section = NSCollectionLayoutSection(group: group)
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        section.decorationItems = [sectionBackgroundDecoration]
        return section
    }
     
    private func settingsSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        let row = indexPath.row
        switch section {
        case .main:
            if row == 0 {
                showExposureNotifcationSettingBtn()
            } else if row == 1 {
                
            } else {
                showSubmitResult()
            }
        case .info:
            break
        case .settings:
            showSetting()
        }
    }
}
