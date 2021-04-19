//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class HomeTraceLocationsTableViewCell: UITableViewCell {

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		cardView.setHighlighted(highlighted, animated: animated)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateIllustration(for: traitCollection)
	}

	// MARK: - Internal

	func configure(with cellModel: HomeTraceLocationsCellModel, onPrimaryAction: @escaping () -> Void) {
		titleLabel.text = cellModel.title
		descriptionLabel.text = cellModel.description
		illustrationView.image = cellModel.image

		button.setTitle(cellModel.buttonTitle, for: .normal)
		button.accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

		button.accessibilityIdentifier = cellModel.accessibilityIdentifier

		self.tintColor = tintColor

		self.onPrimaryAction = onPrimaryAction
	}

	// MARK: - Private

	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!
	@IBOutlet private var illustrationView: UIImageView!
	@IBOutlet private var button: ENAButton!
	@IBOutlet weak var cardView: HomeCardView!
	
	private var onPrimaryAction: (() -> Void)?

	private func setup() {
		updateIllustration(for: traitCollection)
		clipsToBounds = false

		setupAccessibility()
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any, button as Any]

		titleLabel.accessibilityTraits = [.header, .button]
	}

	@IBAction private func primaryActionTriggered() {
		onPrimaryAction?()
	}

}
