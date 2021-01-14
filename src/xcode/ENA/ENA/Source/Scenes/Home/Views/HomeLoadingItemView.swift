//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeLoadingItemView: UIView, HomeItemView, HomeItemViewSeparatorable {

	// MARK: - Overrides

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

	// MARK: - Protocol HomeItemView

	func configure(with viewModel: HomeLoadingItemViewModel) {
		activityIndicatorView.color = viewModel.titleColor
		textLabel?.text = viewModel.title
		textLabel?.textColor = viewModel.titleColor
		separatorView?.backgroundColor = viewModel.separatorColor

		if viewModel.isActivityIndicatorOn {
			activityIndicatorView.startAnimating()
		} else {
			activityIndicatorView.stopAnimating()
		}

		backgroundColor = viewModel.color
	}

	// MARK: - Protocol RiskItemViewSeparatorable

	func hideSeparator() {
		separatorView.isHidden = true
	}

	// MARK: - Private

	@IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet private weak var textLabel: ENALabel!
	@IBOutlet private weak var separatorView: UIView!
	@IBOutlet private weak var stackView: UIStackView!

	private func configureActivityIndicatorView() {
		let greaterThanAccessibilityMedium = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
		if #available(iOS 13.0, *) {
			activityIndicatorView.style = greaterThanAccessibilityMedium ? .large : .medium
		} else {
			activityIndicatorView.style = greaterThanAccessibilityMedium ? .whiteLarge : .white
		}
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			stackView.spacing = 8.0
		} else {
			stackView.spacing = 16.0
		}
	}
}
