//
// 🦠 Corona-Warn-App
//

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
