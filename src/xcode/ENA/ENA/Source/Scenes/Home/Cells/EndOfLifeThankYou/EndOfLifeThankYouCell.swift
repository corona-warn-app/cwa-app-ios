//
// 🦠 Corona-Warn-App
//

import UIKit

final class EndOfLifeThankYouCell: UITableViewCell {
	
	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}
		
		
	// MARK: - Internal

	func configure(with cellModel: EndOfLifeThankYouCellViewModel) {
		titleLabel.text = cellModel.title
		titleLabel.accessibilityIdentifier = cellModel.titleAccessibilityIdentifier
		
		descriptionTextView.attributedText = cellModel.description
		descriptionTextView.accessibilityIdentifier = cellModel.descriptionAccessibilityIdentifier
		
		illustrationImageView.image = cellModel.image
		illustrationImageView.accessibilityIdentifier = cellModel.imageAccessibilityIdentifier
	}

	// MARK: - Private
	
	private func setup() {
		selectionStyle = .none
		updateIllustration(for: traitCollection)
		clipsToBounds = false
		
		descriptionTextView.isUserInteractionEnabled = true
		descriptionTextView.isScrollEnabled = false
		descriptionTextView.isEditable = false
		descriptionTextView.adjustsFontForContentSizeCategory = true
		descriptionTextView.backgroundColor = .clear
		descriptionTextView.delegate = self

		setupAccessibility()
	}
	
	private func updateIllustration(for traitCollection: UITraitCollection) {
		illustrationImageView.isHidden = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
	}
	
	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, descriptionTextView as Any, illustrationImageView as Any]
	}

	@IBOutlet private weak var cardView: HomeCardView!
	@IBOutlet private weak var illustrationImageView: UIImageView!
	@IBOutlet private weak var descriptionTextView: UITextView!
	@IBOutlet private weak var titleLabel: ENALabel!
}

extension EndOfLifeThankYouCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
}
