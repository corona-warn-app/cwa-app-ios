//
// 🦠 Corona-Warn-App
//

import UIKit

final class RiskListItemView: UIView, RiskItemView {

	@IBOutlet var dotLabel: ENALabel!
	@IBOutlet var textLabel: ENALabel!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		let containerInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 0.0)
		stackView.layoutMargins = containerInsets
		stackView.isLayoutMarginsRelativeArrangement = true
		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureStackView()
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			dotLabel.isHidden = true
		} else {
			dotLabel.isHidden = false
		}
	}
}
