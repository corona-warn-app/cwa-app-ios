//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeImageItemView: UIView, HomeItemView, HomeItemViewSeparatorable {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)

		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		configureStackView()
	}

	// MARK: - Protocol HomeItemView

	func configure(with viewModel: HomeImageItemViewModel) {
		iconImageView?.image = UIImage(named: viewModel.iconImageName)
		iconImageView.tintColor = viewModel.iconTintColor
		textLabel?.text = viewModel.title
		textLabel?.textColor = viewModel.titleColor
		separatorView?.backgroundColor = viewModel.separatorColor

		backgroundColor = viewModel.color
		accessibilityLabel = viewModel.title
		isAccessibilityElement = true
		if let containerInsets = viewModel.containerInsets {
			stackView.layoutMargins = containerInsets
		}
	}

	// MARK: - Protocol RiskItemViewSeparatorable

	func hideSeparator() {
		separatorView.isHidden = true
	}

	// MARK: - Private

	@IBOutlet private weak var iconImageView: UIImageView!
	@IBOutlet private weak var textLabel: ENALabel!
	@IBOutlet private weak var separatorView: UIView!
	@IBOutlet private weak var stackView: UIStackView!
	
	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			iconImageView.isHidden = true
		} else {
			iconImageView.isHidden = false
		}
	}

}
