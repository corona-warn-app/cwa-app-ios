//
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
//

import UIKit


typealias HomeSection = HomeViewController.Section
final class HomeCollectionViewDataSource: UICollectionViewDiffableDataSource<HomeSection, UUID> {
	typealias SectionDefintion = HomeViewController.SectionDefinition
	typealias SectionDefintions = [SectionDefintion]
	typealias SectionDefinitionsProvider = () -> SectionDefintions

	init(
		collectionView: HomeCollectionView,
		sectionDefinitionsProvider: @escaping SectionDefinitionsProvider
	) {
		self.sectionDefinitionsProvider = sectionDefinitionsProvider

		super.init(collectionView: collectionView) { _, indexPath, _ -> UICollectionViewCell? in
			let sections = sectionDefinitionsProvider()
			let configurator = sections[indexPath.section].cellConfigurators[indexPath.row]
			let cell = collectionView.dequeueReusableCell(cellType: configurator.viewAnyType, for: indexPath)
			cell.unhighlight()
			configurator.configureAny(cell: cell)
			return cell
		}

	}
	private let sectionDefinitionsProvider: SectionDefinitionsProvider
	private func sectionDefinitions() -> SectionDefintions {
		sectionDefinitionsProvider()
	}

	func applySnapshotFromSections(animatingDifferences: Bool = false) {
		let sections = sectionDefinitions()

		var snapshot = NSDiffableDataSourceSnapshot<HomeSection, UUID>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems( section.cellConfigurators.map { $0.identifier })
		}

		apply(snapshot, animatingDifferences: animatingDifferences)
	}
}
