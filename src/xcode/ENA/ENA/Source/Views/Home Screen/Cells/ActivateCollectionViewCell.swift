//
// 🦠 Corona-Warn-App
//

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
