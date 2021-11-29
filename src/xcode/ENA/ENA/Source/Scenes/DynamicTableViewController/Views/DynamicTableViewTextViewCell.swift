//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewTextViewCell: UITableViewCell, DynamicTableViewTextCell {

	// MARK: - Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		resetMargins()
		configureDynamicType()
		configure(text: "", color: .enaColor(for: .textPrimary1))
	}

	// MARK: - Internal

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

		textView.attributedText = attributedString
		textView.isUserInteractionEnabled = true
		textView.isEditable = false
		textView.adjustsFontForContentSizeCategory = true
	}

	func configure(text: String, textFont: ENAFont, textColor: UIColor = .enaColor(for: .textPrimary1), links: [String: String], linksColor: UIColor) {
		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: textFont.textStyle).scaledFont(size: textFont.fontSize, weight: textFont.fontWeight),
			.foregroundColor: textColor
		]
		let attributedText = NSMutableAttributedString(string: text, attributes: textAttributes)

		// setup link style - only available in UITextView
		textView.linkTextAttributes = [
			.foregroundColor: linksColor,
			.underlineColor: UIColor.clear
		]

		links.forEach { text, link in
			attributedText.mark(text, with: link)
		}
		textView.backgroundColor = .clear
		textView.attributedText = attributedText
	}

	// MARK: - Private

	private let textView = UITextView()

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
		textView.delegate = self

		contentView.addSubview(textView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true

		resetMargins()
	}

	private func resetMargins() {
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.insetsLayoutMarginsFromSafeArea = false
	}
}

// MARK: - Protocol UITextViewDelegate

extension DynamicTableViewTextViewCell: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
}
