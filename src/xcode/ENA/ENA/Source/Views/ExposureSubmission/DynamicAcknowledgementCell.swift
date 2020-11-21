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
			let label = UILabel()
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.attributedText = bulletPointString(string)
			contentStackView.addArrangedSubview(label)
		}
	}

	// MARK: - Private helpers

	private func setup() {
		cardView.layer.cornerRadius = 16
	}

	private func bulletPointString(_ from: NSAttributedString) -> NSAttributedString {
		let paragraphStyle = NSMutableParagraphStyle()
		let nonOptions = [NSTextTab.OptionKey: Any]()
		paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20, options: nonOptions)]
		paragraphStyle.defaultTabInterval = 20

		let font = from.attribute(.font, at: 0, effectiveRange: nil) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
		let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.black]

		let bullet = "•"
		let prefixString = "\(bullet)\t"
		let attributedString = NSMutableAttributedString(string: prefixString)
		attributedString.append(from)

		attributedString.addAttributes(
			[NSAttributedString.Key.paragraphStyle: paragraphStyle],
			range: NSRange(location: 0, length: attributedString.length))

		let string = NSString(string: prefixString)
		let rangeForBullet = string.range(of: bullet)
		attributedString.addAttributes(bulletAttributes, range: rangeForBullet)

		return attributedString
	}
}
