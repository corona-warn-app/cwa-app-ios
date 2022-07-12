////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionTestOwnerCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Internal
	
	func configure(
		headline: String,
		subheadline: String,
		iconImage: UIImage?,
		accessibilityIdentifier: String
	) {
		self.headlineLabel.text = headline
		self.subheadlineLabel.text = subheadline
		self.iconImageView.image = iconImage
		self.accessibilityIdentifier = accessibilityIdentifier
		self.accessibilityTraits = .button
	}

	// MARK: - Private

	@IBOutlet private weak var headlineLabel: ENALabel!
	@IBOutlet private weak var subheadlineLabel: ENALabel!
	@IBOutlet private weak var iconImageView: UIImageView!
}
