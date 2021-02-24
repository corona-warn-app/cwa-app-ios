//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeShownPositiveTestResultTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		stackView.setCustomSpacing(32.0, after: topContainer)
		stackView.setCustomSpacing(32.0, after: statusContainer)
		stackView.setCustomSpacing(8.0, after: noteLabel)

		setupAccessibility()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		nextButton.titleLabel?.lineBreakMode = traitCollection.preferredContentSizeCategory >= .accessibilityMedium ? .byTruncatingMiddle : .byWordWrapping
		configureStackView()
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		containerView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with cellModel: HomeShownPositiveTestResultCellModel, onPrimaryAction: @escaping () -> Void) {
		containerView.backgroundColor = cellModel.backgroundColor

		titleLabel.text = cellModel.title
		titleLabel.textColor = cellModel.titleColor

		topContainer.accessibilityLabel = cellModel.title

		statusTitleLabel.text = cellModel.statusTitle
		statusSubtitleLabel.text = cellModel.statusSubtitle

		statusTitleLabel.textColor = cellModel.statusTitleColor
		statusSubtitleLabel.textColor = cellModel.statusTitleColor

		statusLineView.backgroundColor = cellModel.statusLineColor
		statusImageView.image = UIImage(named: cellModel.statusImageName)

		noteLabel.text = cellModel.noteTitle

		UIView.performWithoutAnimation {
			nextButton.setTitle(cellModel.buttonTitle, for: .normal)
		}

		// Configure risk stack view

		homeItemStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for itemModel in cellModel.homeItemViewModels {
			let nibName = String(describing: itemModel.ViewType)
			let nib = UINib(nibName: nibName, bundle: .main)

			if let itemView = nib.instantiate(withOwner: self, options: nil).first as? HomeItemViewAny {
				homeItemStackView.addArrangedSubview(itemView)
				itemView.configureAny(with: itemModel)
			}
		}

		homeItemStackView.isHidden = homeItemStackView.arrangedSubviews.isEmpty

		self.onPrimaryAction = onPrimaryAction
	}

	// MARK: - Private

	@IBOutlet private weak var titleLabel: ENALabel!

	@IBOutlet private weak var statusTitleLabel: ENALabel!
	@IBOutlet private weak var statusSubtitleLabel: ENALabel!
	@IBOutlet private weak var statusImageView: UIImageView!
	@IBOutlet private weak var statusLineView: UIView!

	@IBOutlet private weak var noteLabel: ENALabel!
	@IBOutlet private weak var nextButton: ENAButton!

	@IBOutlet private weak var containerView: HomeCardView!
	@IBOutlet private weak var topContainer: UIView!
	@IBOutlet private weak var statusContainer: UIView!
	@IBOutlet private weak var stackView: UIStackView!
	@IBOutlet private weak var homeItemStackView: UIStackView!

	private var onPrimaryAction: (() -> Void)?

	@IBAction private func nextButtonTapped(_: UIButton) {
		onPrimaryAction?()
	}

	private func configureStackView() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			statusImageView.isHidden = true
		} else {
			statusImageView.isHidden = false
		}
	}

	func setupAccessibility() {
		containerView.accessibilityElements = [topContainer as Any, statusContainer as Any, noteLabel as Any, homeItemStackView as Any, nextButton as Any]

		topContainer.isAccessibilityElement = true
		topContainer.accessibilityTraits = [.button, .header]
	}

}
