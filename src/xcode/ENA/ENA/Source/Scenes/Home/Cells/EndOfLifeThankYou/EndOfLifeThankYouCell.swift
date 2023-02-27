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
		
		descriptionLabel.text = cellModel.description
		descriptionLabel.accessibilityIdentifier = cellModel.descriptionAccessibilityIdentifier
		
		illustrationImageView.image = cellModel.image
		illustrationImageView.accessibilityIdentifier = cellModel.imageAccessibilityIdentifier
	}

	// MARK: - Private
	
	private func setup() {
		updateIllustration(for: traitCollection)
		clipsToBounds = false

		setupAccessibility()
	}
	
	private func updateIllustration(for traitCollection: UITraitCollection) {
illustrationImageView.isHidden = traitCollection.preferredContentSizeCategory >= .accessibilityLarge
	}
	
	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any, illustrationImageView as Any]
	}

	@IBOutlet private weak var cardView: HomeCardView!
	@IBOutlet private weak var illustrationImageView: UIImageView!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var titleLabel: ENALabel!
}
