//
// 🦠 Corona-Warn-App
//

import UIKit

class MainSettingsCell: UITableViewCell {
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var stateLabel: UILabel!
	@IBOutlet var imageContainer: UIView!

	@IBOutlet var descriptionLabelLeadingConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionLabelTrailingConstraint: NSLayoutConstraint!
	@IBOutlet var imageContainerFirstBaselineConstraint: NSLayoutConstraint!
	@IBOutlet var imageContainerCenterConstraint: NSLayoutConstraint!

	@IBOutlet var stateLabelLeading: NSLayoutConstraint!
	@IBOutlet var stateLabelTop: NSLayoutConstraint!
	@IBOutlet var stateLabelLeadingLarge: NSLayoutConstraint!
	@IBOutlet var stateLabelTopLarge: NSLayoutConstraint!
	@IBOutlet var descriptionLabelBottom: NSLayoutConstraint!
	@IBOutlet var disclosureIndicatorLeading: NSLayoutConstraint!
	@IBOutlet var disclosureIndicatorLeadingLarge: NSLayoutConstraint!

	private var regularConstraints: [NSLayoutConstraint] = []
	private var largeTextConstraints: [NSLayoutConstraint] = []

	private let labelPadding: CGFloat = 10

	override func awakeFromNib() {
		super.awakeFromNib()

		setLayoutConstraints()
	}

	func configure(model: SettingsViewModel.CellModel) {
		iconImageView.image = UIImage(named: model.icon)
		stateLabel.text = model.state ?? model.stateInactive
		accessibilityIdentifier = model.accessibilityIdentifier

		updateDescriptionLabel(model.description)
		updateLayoutConstraints()
	}

	private func setLayoutConstraints() {
		regularConstraints = [imageContainerFirstBaselineConstraint, descriptionLabelTrailingConstraint, descriptionLabelBottom, stateLabelLeading, stateLabelTop, disclosureIndicatorLeading]

		let labelHalfCapHeight = descriptionLabel.font.capHeight / 2
		imageContainerFirstBaselineConstraint.constant = labelHalfCapHeight

		largeTextConstraints = [descriptionLabelLeadingConstraint, imageContainerFirstBaselineConstraint, stateLabelTopLarge, stateLabelLeadingLarge, disclosureIndicatorLeadingLarge]
	}

	private func updateLayoutConstraints() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			NSLayoutConstraint.deactivate(regularConstraints)
			NSLayoutConstraint.activate(largeTextConstraints)
		} else {
			NSLayoutConstraint.deactivate(largeTextConstraints)
			NSLayoutConstraint.activate(regularConstraints)
		}
	}

	private func updateDescriptionLabel(_ value: String) {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.setParagraphStyle(NSParagraphStyle.default)

		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			paragraphStyle.firstLineHeadIndent = imageContainer.frame.size.width + labelPadding
		}

		let attributedString = NSAttributedString(
			string: value,
			attributes: [
				NSAttributedString.Key.paragraphStyle: paragraphStyle,
				NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)
			]
		)
		descriptionLabel.attributedText = attributedString
	}
}
