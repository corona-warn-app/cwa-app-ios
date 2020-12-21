//
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class DynamicLegalCell: UITableViewCell {

	@IBOutlet private var cardView: UIView!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var descriptionLabel: ENALabel!

	@IBOutlet private var contentStackView: UIStackView!

	static let reuseIdentifier = "DynamicLegalCell"

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		guard cardView != nil else { return }
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	/// Configure the cell to show a list of bullet points.
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - description: Optional description text.
	///   - bulletPoints: A list of strings to be prefixed with bullet points.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	func configure(title: NSAttributedString, description: NSAttributedString?, bulletPoints: [NSAttributedString]?, accessibilityIdentifier: String? = nil) {
		// create a fake label to get the default font for these
		let label = ENALabel()
		// 'bulletized' strings
		let textBlocks = bulletPoints?.map({ $0.bulletPointString(bulletPointFont: label.font) }) ?? []
		configure(title: title, description: description, textBlocks: textBlocks, accessibilityIdentifier: accessibilityIdentifier)
	}

	/// Configure the cell to show a list of bullet points.
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - description: Optional description text.
	///   - textBlocks: A list of strings to be shown 'as is' without further modification.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
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
		backgroundColor = .enaColor(for: .background)
	}
}
