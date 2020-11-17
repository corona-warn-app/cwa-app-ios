//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewTextViewCell: UITableViewCell, DynamicTableViewTextCell {
	private let textView = UITextView()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	private func setup() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)
		textView.backgroundColor = .enaColor(for: .background)

		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		textView.isEditable = false
		// The two below settings make the UITextView look more like a UILabel
		// By default, UITextView has some insets & padding that differ from a UILabel.
		// For example, there are insets different from UILabel that cause the text to be a little offset
		// at all sides when compared to a UILabel.
		// As this cell is used together with regular UILabel-backed cells in the same table,
		// we want to ensure that our text view looks exactly like the label-backed cells.
		textView.textContainerInset = .zero
		textView.textContainer.lineFragmentPadding = .zero
		textView.tintColor = .enaColor(for: .textTint)

		contentView.addSubview(textView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true

		resetMargins()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}

	func configureDynamicType(size: CGFloat = 17, weight: UIFont.Weight = .regular, style: UIFont.TextStyle = .body) {
		textView.font = UIFont.preferredFont(forTextStyle: style).scaledFont(size: size, weight: weight)
		textView.adjustsFontForContentSizeCategory = true
	}

	func configure(text: String, color: UIColor? = nil) {
		textView.text = text
		textView.textColor = color ?? .enaColor(for: .textPrimary1)
	}

	func configureAccessibility(label: String? = nil, identifier: String? = nil, traits: UIAccessibilityTraits = .staticText) {
		textView.accessibilityLabel = label
		textView.accessibilityIdentifier = identifier
		accessibilityTraits = traits
	}

	func configureTextView(dataDetectorTypes: UIDataDetectorTypes) {
		textView.dataDetectorTypes = dataDetectorTypes
	}

	func configureAsLink(placeholder: String, urlString: String, font: ENAFont) {
		guard let url = URL(string: urlString) else {
			return
		}
		let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: font.textStyle).scaledFont(size: font.fontSize, weight: font.fontWeight), .link: url]
		let attributedString = NSMutableAttributedString(string: placeholder, attributes: textAttributes)

		self.textView.attributedText = attributedString
		self.textView.isUserInteractionEnabled = true
		self.textView.isEditable = false
		self.textView.adjustsFontForContentSizeCategory = true
	}
}
