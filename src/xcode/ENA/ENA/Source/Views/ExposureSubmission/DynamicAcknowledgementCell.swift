//
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class DynamicAcknowledgementCell: UITableViewCell {

	@IBOutlet private var cardView: UIView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!

	@IBOutlet private var contentStackView: UIStackView!

	static let reuseIdentifier = "DynamicAcknowledgementCell"

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		guard cardView != nil else { return }
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	func configure(title: NSAttributedString, description: NSAttributedString?, bulletPoints: [NSAttributedString], accessibilityIdentifier: String? = nil) {
		// create a fake label to get the default font for these
		let label = ENALabel()
		// 'bulletized' strings
		let textBlocks = bulletPoints.map({ $0.bulletPointString(bulletPointFont: label.font) })
		configure(title: title, description: description, textBlocks: textBlocks, accessibilityIdentifier: accessibilityIdentifier)
	}

	func configure(title: NSAttributedString, description: NSAttributedString?, textBlocks: [NSAttributedString], accessibilityIdentifier: String? = nil) {
		titleLabel.attributedText = title
		descriptionLabel.attributedText = description

		self.accessibilityIdentifier = accessibilityIdentifier

		// pruning stack view before setting (new) label
		contentStackView.removeAllArrangedSubviews()

		textBlocks.forEach { string in
			let label = ENALabel()
			label.style = .body
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.attributedText = string
			contentStackView.addArrangedSubview(label)
		}
	}

	// MARK: - Private helpers

	private func setup() {
		cardView.layer.cornerRadius = 16
	}
}
