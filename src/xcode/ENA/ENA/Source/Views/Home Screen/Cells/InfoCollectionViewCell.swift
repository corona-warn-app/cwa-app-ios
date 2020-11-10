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

class InfoCollectionViewCell: UICollectionViewCell {
	@IBOutlet var chevronImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var bodyLabel: UILabel!

	@IBOutlet var topDividerView: UIView!
	@IBOutlet var bottomDividerView: UIView!
	@IBOutlet var bottomDividerLeadingConstraint: NSLayoutConstraint!

	override func awakeFromNib() {
		super.awakeFromNib()
		setupAccessibility()
	}

	func configure(title: String, description: String?, accessibilityIdentifier: String?) {
		titleLabel.text = title
		bodyLabel.text = description

		bodyLabel.isHidden = (nil == description)

		if let description = description {
			accessibilityLabel = "\(title)\n\n\(description)"
		} else {
			accessibilityLabel = "\(title)"
		}

		self.accessibilityIdentifier = accessibilityIdentifier
	}

	private func setupAccessibility() {
		isAccessibilityElement = true
		accessibilityTraits = .button
	}
}
