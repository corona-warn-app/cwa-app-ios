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

import UIKit

protocol HomeLayoutDelegate: AnyObject {
	func homeLayout(homeLayout: HomeLayout, for sectionIndex: Int) -> HomeViewController.Section?
}

final class HomeLayout {
	weak var delegate: HomeLayoutDelegate?

	func collectionLayout() -> UICollectionViewLayout {
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

	private func layoutSection(for section: HomeViewController.Section, layoutEnvironment _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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
		item.edgeSpacing = .init(leading: .none, top: .fixed(16.0), trailing: .none, bottom: .none)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1000.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		let insets: CGFloat = 16.0
		section.contentInsets = .init(top: 0.0, leading: insets, bottom: 0.0, trailing: insets)

		let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionSystemBackgroundDecorationView.reusableViewIdentifier)
		section.decorationItems = [sectionBackgroundDecoration]

		return section
	}

	private func infoSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		let insets: CGFloat = 0.0
		section.contentInsets = .init(top: insets, leading: insets, bottom: 0.0, trailing: insets)

		return section
	}

	private func settingsSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		let insets: CGFloat = 0.0
		section.contentInsets = .init(top: insets, leading: insets, bottom: 0.0, trailing: insets)

		return section
	}
}
