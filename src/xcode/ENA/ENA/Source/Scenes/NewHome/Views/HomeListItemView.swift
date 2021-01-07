//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeListItemView: UIView, HomeItemView {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		stackView.layoutMargins = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 0.0)
		stackView.isLayoutMarginsRelativeArrangement = true

		configureStackView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		configureStackView()
	}

	// MARK: - Protocol HomeItemView

	func configure(with viewModel: HomeListItemViewModel) {
		textLabel.text = viewModel.text
		textLabel.textColor = viewModel.textColor

		dotLabel.textColor = viewModel.textColor
	}

	// MARK: - Private

	@IBOutlet private weak var dotLabel: ENALabel!
	@IBOutlet private weak var textLabel: ENALabel!
	@IBOutlet private weak var stackView: UIStackView!

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			dotLabel.isHidden = true
		} else {
			dotLabel.isHidden = false
		}
	}

}
