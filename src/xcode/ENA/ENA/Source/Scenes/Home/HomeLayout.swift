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
	func homeLayoutSection(for sectionIndex: Int) -> HomeViewController.Section?
}

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
