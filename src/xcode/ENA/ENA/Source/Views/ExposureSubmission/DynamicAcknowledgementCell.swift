//
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class DynamicAcknowledgementCell: UITableViewCell {

	@IBOutlet var cardView: UIView!
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var descriptionLabel: ENALabel!

	@IBOutlet var contentStackView: UIStackView!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		guard nil != cardView else { return }
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	func configure(title: NSAttributedString, description: NSAttributedString?, bulletPoints: [NSAttributedString], accessibilityIdentifier: String? = nil) {
		titleLabel.attributedText = title
		descriptionLabel.attributedText = description

		self.accessibilityIdentifier = accessibilityIdentifier

		bulletPoints.forEach { string in
			let label = ENALabel()
			label.style = .body
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.attributedText = bulletPointString(string, font: label.font)
			contentStackView.addArrangedSubview(label)
		}
	}

	// MARK: - Private helpers

	private func setup() {
		cardView.layer.cornerRadius = 16
	}

	private func bulletPointString(_ from: NSAttributedString, font: UIFont) -> NSAttributedString {
		// <bullet point>|--- indentation ---|<rest of text>
		let indentation: CGFloat = 20.0
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.tabStops = [NSTextTab(textAlignment: .natural, location: indentation, options: [:])]
		paragraphStyle.defaultTabInterval = indentation
		paragraphStyle.headIndent = indentation
		paragraphStyle.paragraphSpacing = 8

		let bulletAttributes: [NSAttributedString.Key: Any] = [
			.font: font.scaledFont(size: font.pointSize, weight: .black),
			.foregroundColor: UIColor.label
		]

		let bullet = "\u{2022}"
		let prefixString = "\(bullet)\t"
		let attributedString = NSMutableAttributedString(string: prefixString)
		attributedString.append(from)

		// style bullet point
		let string = NSString(string: prefixString)
		let rangeForBullet = string.range(of: bullet)
		attributedString.addAttributes(bulletAttributes, range: rangeForBullet)

		// style text paragraphs
		attributedString.addAttributes(
			[NSAttributedString.Key.paragraphStyle: paragraphStyle],
			range: NSRange(location: 0, length: attributedString.length))

		return attributedString
	}
}
