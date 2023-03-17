//
// 🦠 Corona-Warn-App
//

import UIKit

final class EndOfLifeThankYouCell: UITableViewCell {
	
	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setupView()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setupView()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateView(for: traitCollection)
		setupAccessibility()
	}
		
		
	// MARK: - Internal

	func configure(with cellModel: EndOfLifeThankYouCellViewModel) {
		titleLabel.text = cellModel.title
		titleLabel.accessibilityIdentifier = cellModel.titleAccessibilityIdentifier
		
		titleLabelAccessibilityLarge.text = cellModel.title
		titleLabelAccessibilityLarge.accessibilityIdentifier = cellModel.titleAccessibilityIdentifier
		
		descriptionTextView.attributedText = cellModel.description
		descriptionTextView.accessibilityIdentifier = cellModel.descriptionAccessibilityIdentifier
		
		illustrationImageView.image = cellModel.image
		illustrationImageView.accessibilityIdentifier = cellModel.imageAccessibilityIdentifier
	}

	// MARK: - Private
	
	private func setupView() {
		selectionStyle = .none
		updateView(for: traitCollection)

		illustrationImageView.clipsToBounds = true
		illustrationImageView.layer.cornerRadius = HomeCardView.cornerRadius
		illustrationImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		
		descriptionTextView.isUserInteractionEnabled = true
		descriptionTextView.isScrollEnabled = false
		descriptionTextView.isEditable = false
		descriptionTextView.adjustsFontForContentSizeCategory = true
		descriptionTextView.backgroundColor = .clear
		descriptionTextView.delegate = self
		descriptionTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textTint)]

		setupAccessibility()
	}
	
	private func updateView(for traitCollection: UITraitCollection) {
		let stackViewTopHeight: CGFloat = traitCollection.preferredContentSizeCategory >= .accessibilityLarge ? 20 : 0
		stackViewTopConstraint.constant = stackViewTopHeight
		
		illustrationImageView.isHidden = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
		titleLabel.isHidden = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
		titleLabelAccessibilityLarge.isHidden = traitCollection.preferredContentSizeCategory < .accessibilityLarge
	}
	
	private func setupAccessibility() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			cardView.accessibilityElements = [titleLabelAccessibilityLarge as Any, descriptionTextView as Any, illustrationImageView as Any]
		} else {
			cardView.accessibilityElements = [titleLabel as Any, descriptionTextView as Any, illustrationImageView as Any]
		}
	}

	@IBOutlet private weak var cardView: HomeCardView!
	@IBOutlet private weak var illustrationImageView: UIImageView!
	@IBOutlet private weak var descriptionTextView: UITextView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var titleLabelAccessibilityLarge: ENALabel!
	@IBOutlet private weak var stackViewTopConstraint: NSLayoutConstraint!
	
}

// MARK: - UITextViewDelegate

extension EndOfLifeThankYouCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
}
