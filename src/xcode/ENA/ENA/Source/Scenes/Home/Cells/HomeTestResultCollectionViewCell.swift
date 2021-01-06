//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol HomeTestResultCollectionViewCellDelegate: class {
	func testResultCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeTestResultCollectionViewCell)
}

class HomeTestResultCollectionViewCell: HomeCardCollectionViewCell {
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var subtitleLabel: ENALabel!
	@IBOutlet var descriptionLabel: ENALabel!
	@IBOutlet var illustrationView: UIImageView!
	@IBOutlet var button: ENAButton!
	@IBOutlet var stackView: UIStackView!

	weak var delegate: HomeTestResultCollectionViewCellDelegate?

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		subtitleLabel.textColor = tintColor
		updateIllustration(for: traitCollection)

		setupAccessibility()
	}

	func configure(title: String, subtitle: String? = nil, description: String, button buttonTitle: String, image: UIImage?, tintColor: UIColor = .enaColor(for: .textPrimary1), accessibilityIdentifier: String?) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		descriptionLabel.text = description
		illustrationView?.image = image

		button.setTitle(buttonTitle, for: .normal)
		button.accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

		subtitleLabel.isHidden = (nil == subtitle)
		button.accessibilityIdentifier = accessibilityIdentifier

		self.tintColor = tintColor
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		subtitleLabel.textColor = tintColor
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}

	@IBAction func primaryActionTriggered() {
		delegate?.testResultCollectionViewCellPrimaryActionTriggered(self)
	}

	func setupAccessibility() {
		titleLabel.isAccessibilityElement = true
		subtitleLabel.isAccessibilityElement = true
		descriptionLabel.isAccessibilityElement = true
		isAccessibilityElement = false

		titleLabel.accessibilityTraits = [.header, .button]
	}
}
