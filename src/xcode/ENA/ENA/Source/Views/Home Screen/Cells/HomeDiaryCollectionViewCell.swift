//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol HomeDiaryCollectionViewCellDelegate: class {
	func diaryCollectionViewCellPrimaryActionTriggered(_ collectionViewCell: HomeDiaryCollectionViewCell)
}

class HomeDiaryCollectionViewCell: HomeCardCollectionViewCell {

	// MARK: - Init

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		subtitleLabel.textColor = tintColor
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	weak var delegate: HomeDiaryCollectionViewCellDelegate?

	private func setup() {
		subtitleLabel.textColor = tintColor
		updateIllustration(for: traitCollection)

		setupAccessibility()
	}

	func configure(
		title: String,
		subtitle: String? = nil,
		description: String,
		button buttonTitle: String,
		image: UIImage?,
		tintColor: UIColor = .enaColor(for: .textPrimary1),
		accessibilityIdentifier: String?
	) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		descriptionLabel.text = description
		illustrationView.image = image

		button.setTitle(buttonTitle, for: .normal)
		button.accessibilityIdentifier = AccessibilityIdentifiers.Home.submitCardButton

		subtitleLabel.isHidden = (nil == subtitle)
		button.accessibilityIdentifier = accessibilityIdentifier

		self.tintColor = tintColor
	}

	func setupAccessibility() {
		titleLabel.isAccessibilityElement = true
		subtitleLabel.isAccessibilityElement = true
		descriptionLabel.isAccessibilityElement = true
		isAccessibilityElement = false

		titleLabel.accessibilityTraits = [.header, .button]
	}

	// MARK: - Private

	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var subtitleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!
	@IBOutlet private var illustrationView: UIImageView!
	@IBOutlet private var button: ENAButton!
	@IBOutlet private var stackView: UIStackView!

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .accessibilityLarge {
			illustrationView.superview?.isHidden = true
		} else {
			illustrationView.superview?.isHidden = false
		}
	}

	@IBAction func primaryActionTriggered() {
		delegate?.diaryCollectionViewCellPrimaryActionTriggered(self)
	}

}
