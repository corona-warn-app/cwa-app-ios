//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeTextItemView: UIView, HomeItemView, HomeItemViewSeparatorable {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		layoutMargins = .init(top: titleTopPadding, left: 0, bottom: titleTopPadding, right: 0)
	}

	// MARK: - Protocol HomeItemView

	func configure(with viewModel: HomeTextItemViewModel) {
		titleLabel?.text = viewModel.title
		titleLabel?.textColor = viewModel.titleColor

		separatorView?.backgroundColor = viewModel.separatorColor

		backgroundColor = viewModel.color
	}

	// MARK: - Protocol HomeItemViewSeparatorable

	func hideSeparator() {
		separatorView.isHidden = true
	}

	// MARK: - Private

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var separatorView: UIView!

	private let titleTopPadding: CGFloat = 8.0

}
