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

class ActivateCollectionViewCell: HomeCardCollectionViewCell {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var viewContainer: UIView!

	override func awakeFromNib() {
		super.awakeFromNib()

		isAccessibilityElement = true
		accessibilityTraits = .button
	}

	func configure(title: String, icon: UIImage?, animationImages: [UIImage]? = nil, accessibilityIdentifier: String) {
		self.titleLabel.text = title
		self.iconImageView.image = icon
		self.accessibilityIdentifier = accessibilityIdentifier
		self.accessibilityLabel = title

		if let animationImages = animationImages {
			iconImageView.animationImages = animationImages
			iconImageView.animationDuration = Double(animationImages.count) / 30

			if !iconImageView.isAnimating {
				iconImageView.startAnimating()
			}
		} else if iconImageView.isAnimating {
			iconImageView.stopAnimating()
		}
	}
}
