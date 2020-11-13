//
// 🦠 Corona-Warn-App
//

import UIKit

final class RiskLoadingItemView: UIView, RiskItemView, RiskItemViewSeparatorable {

	@IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet var textLabel: ENALabel!
	@IBOutlet var separatorView: UIView!
	@IBOutlet var stackView: UIStackView!

	override func awakeFromNib() {
		super.awakeFromNib()
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
		configureActivityIndicatorView()
		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureActivityIndicatorView()
		configureStackView()
	}

	private func configureActivityIndicatorView() {
		let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
		activityIndicatorView.style = greaterThanAccessibilityMedium ? .large : .medium
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			stackView.spacing = 8.0
		} else {
			stackView.spacing = 16.0
		}
	}

	func hideSeparator() {
		separatorView.isHidden = true
	}
}
