//
// 🦠 Corona-Warn-App
//

import UIKit

final class RiskImageItemView: UIView, RiskItemView, RiskItemViewSeparatorable {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var textLabel: ENALabel!
	@IBOutlet var separatorView: UIView!
	@IBOutlet var stackView: UIStackView!

	var containerInsets = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0) {
		didSet {
			updateContainerInsets()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		stackView.isLayoutMarginsRelativeArrangement = true
		updateContainerInsets()
		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureStackView()
	}
	
	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			iconImageView.isHidden = true
		} else {
			iconImageView.isHidden = false
		}
	}

	private func updateContainerInsets() {
		stackView.layoutMargins = containerInsets
	}

	func hideSeparator() {
		separatorView.isHidden = true
	}
}
