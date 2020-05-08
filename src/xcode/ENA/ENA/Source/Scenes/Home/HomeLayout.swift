//
//  HomeLayout.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol HomeLayoutDelegate: AnyObject {
    func homeLayout(homeLayout: HomeLayout, for sectionIndex: Int) -> HomeViewController.Section?
}

final class HomeLayout {
    
    weak var delegate: HomeLayoutDelegate?
    
    func collectionLayout() -> UICollectionViewLayout {
        let x = UIButton()
        x.titleLabel?.text = "Welcome_Screen_Titl".localized
        
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [unowned self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let homeSection = self.delegate?.homeLayout(homeLayout: self, for: sectionIndex) else { return nil }
            let section = self.layoutSection(for: homeSection, layoutEnvironment: layoutEnvironment)
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 32.0
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
         config.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        layout.register(SectionSystemBackgroundDecorationView.self, forDecorationViewOfKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        
        return layout
    }
    
    private func layoutSection(for section: HomeViewController.Section, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch section {
        case .actions:
            return mainSection()
        case .infos:
            return infoSection()
        case .settings:
            return settingsSection()
        }
    }
    
    private func mainSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300.0))
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let itemSize3 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300.0))
        let item3 = NSCollectionLayoutItem(layoutSize: itemSize3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1000.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item, item2, item3])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        let insets: CGFloat = 16.0
        section.contentInsets = .init(top: insets, leading: insets, bottom: 0.0, trailing: insets)
        
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        section.decorationItems = [sectionBackgroundDecoration]
        
        return section
    }
    
    private func infoSection() -> NSCollectionLayoutSection {
        
        let itemSize1 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
        let item1 = NSCollectionLayoutItem(layoutSize: itemSize1)
        item1.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: .fixed(8))
        let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item1, item2])
        group.interItemSpacing = .fixed(4)
        
        let section = NSCollectionLayoutSection(group: group)
        let insets: CGFloat = 16.0
        section.contentInsets = .init(top: insets, leading: insets, bottom: 0.0, trailing: insets)

        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
        section.decorationItems = [sectionBackgroundDecoration]
        return section
    }
     
    private func settingsSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let insets: CGFloat = 16.0
        section.contentInsets = .init(top: insets, leading: insets, bottom: 0.0, trailing: insets)

        return section
    }
    
}
