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

class HomeInfoCellConfigurator: CollectionViewCellConfigurator {
	
	var title: String
	var description: String?
	var position: CellConfiguratorPositionInSection
	var accessibilityIdentifier: String?

	init(title: String, description: String?, position: CellConfiguratorPositionInSection, accessibilityIdentifier: String?) {
		self.title = title
		self.description = description
		self.position = position
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	func configure(cell: InfoCollectionViewCell) {
		cell.backgroundColor = .enaColor(for: .background)
		cell.configure(title: title, description: description, accessibilityIdentifier: accessibilityIdentifier)

		cell.topDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)
		cell.bottomDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)

		configureBorders(in: cell)
	}

	func configureBorders(in cell: InfoCollectionViewCell) {
		switch position {
		case .first:
			cell.topDividerView.isHidden = false
			cell.bottomDividerLeadingConstraint.constant = 15.0
		case .other:
			cell.topDividerView.isHidden = true
			cell.bottomDividerLeadingConstraint.constant = 15.0
		case .last:
			cell.topDividerView.isHidden = true
			cell.bottomDividerLeadingConstraint.constant = 0.0
		}
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(title)
		hasher.combine(description)
		hasher.combine(position)
		hasher.combine(accessibilityIdentifier)
	}

	static func == (lhs: HomeInfoCellConfigurator, rhs: HomeInfoCellConfigurator) -> Bool {
		lhs.title == rhs.title &&
		lhs.description == rhs.description &&
		lhs.position == rhs.position &&
		lhs.accessibilityIdentifier == rhs.accessibilityIdentifier
	}
}
