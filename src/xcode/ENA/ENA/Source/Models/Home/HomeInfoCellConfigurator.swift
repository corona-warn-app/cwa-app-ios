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

	let identifier = UUID()
	
	var title: String
	var body: String?
	var position: CellConfiguratorPositionInSection
	var accessibilityIdentifier: String?

	init(title: String, body: String?, position: CellConfiguratorPositionInSection, accessibilityIdentifier: String?) {
		self.title = title
		self.body = body
		self.position = position
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	func configure(cell: InfoCollectionViewCell) {
		cell.backgroundColor = UIColor.preferredColor(for: .backgroundPrimary)
		cell.chevronImageView.image = UIImage(systemName: "chevron.right")
		cell.titleLabel.text = title
		cell.bodyLabel.text = body
		cell.bodyLabel.textColor = UIColor.preferredColor(for: .textPrimary2)
		cell.bodyLabel.isHidden = (body == nil)

		cell.topDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)
		cell.bottomDividerView.backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.3)

		configureBorders(in: cell)
		setupAccessibility(for: cell)
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

	func setupAccessibility(for cell: InfoCollectionViewCell) {
		cell.titleLabel.isAccessibilityElement = true
		cell.titleLabel.accessibilityIdentifier = accessibilityIdentifier
	}
}
