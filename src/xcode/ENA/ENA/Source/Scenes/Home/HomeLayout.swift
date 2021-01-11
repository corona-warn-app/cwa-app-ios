//
// 🦠 Corona-Warn-App
//

import UIKit
import IBPCollectionViewCompositionalLayout

protocol HomeLayoutDelegate: AnyObject {
	func homeLayoutSection(for sectionIndex: Int) -> HomeViewController.Section?
}

typealias UICollectionViewCompositionalLayoutSectionProvider = (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?

extension UICollectionViewLayout {
	static let topInset: CGFloat = 32.0
	static let bottomBackgroundOverflowHeight: CGFloat = UIScreen.main.bounds.height

	class func homeLayout(delegate: HomeLayoutDelegate) -> UICollectionViewLayout {
		let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
			guard let homeSection = delegate.homeLayoutSection(for: sectionIndex) else { return nil }
			let section = layoutSection(for: homeSection, layoutEnvironment: layoutEnvironment)
			return section
		}

		let config = UICollectionViewCompositionalLayoutConfiguration()

		let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
		layout.register(SectionSystemBackgroundDecorationView.self, forDecorationViewOfKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)

		return layout
	}
	
	private static func layoutSection(for section: HomeViewController.Section, layoutEnvironment _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		switch section {
		case .actions:
			return mainSection()
		case .infos:
			return infoSection()
		case .settings:
			return settingsSection()
		}
	}

	private static func mainSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1000.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = .init(top: 0.0, leading: 16.0, bottom: 32.0, trailing: 16.0)
		section.interGroupSpacing = 32.0

		return section
	}

	private static func infoSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
		section.decorationItems = [sectionBackgroundDecoration]

		return section
	}

	private static func settingsSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = .init(top: 32.0, leading: 0.0, bottom: 32.0 + bottomBackgroundOverflowHeight, trailing: 0.0)

		let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
		section.decorationItems = [sectionBackgroundDecoration]

		return section
	}
}
