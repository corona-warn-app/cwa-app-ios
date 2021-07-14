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
		lastHTMLString = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
		   let previousHTMLString = lastHTMLString {
			configure(htmlString: previousHTMLString)
		}
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

	func configure(htmlString: String) {
		guard let htmlString = self.htmlString(with: htmlString),
			  let htmlData = htmlString.data(using: .unicode) else {
			Log.debug("failed to encode html string to data")
			return
		}

		do {
			textView.attributedText = try NSAttributedString(
				data: htmlData,
				options: [
					NSAttributedString.DocumentReadingOptionKey.documentType:
						NSAttributedString.DocumentType.html
				],
				documentAttributes: nil
			)
		} catch {
			Log.error("Failed to create attributed string from html data")
		}
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

	private var lastHTMLString: String?

	private func htmlString(with content: String) -> String? {
		lastHTMLString = content
		let cssStyle = traitCollection.userInterfaceStyle == .dark ? darkCssStyle : lightCssStyle
		return String(format: htmlTemplate, cssStyle, content)
	}

	private let htmlTemplate = """
		<!DOCTYPE html>
		<html lang="en">
		<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
		<style>%@</style>
		</head>
		<body>%@</body>
		</html>
		"""

	private let lightCssStyle = """
		* {
			margin: 0;
			padding: 0;
		}

		html, body, table {
			font-family: -apple-system, BlinkMacSystemFont, "Segoe UI",
			"Roboto", "Oxygen", "Ubuntu", "Helvetica Neue", Arial, sans-serif;
		}

		@supports (font: -apple-system-body) {
			html, body, table {
				font: -apple-system-body !important;
			}
		}
		a:link, a:visited {
			text-decoration: none;
			color: #007fad;
		}
		p {
			font-size: 1.0em;
			font-weight: normal;
		}
		body {
			color: black;
		}
		"""

	private let darkCssStyle = """
		* {
			margin: 0;
			padding: 0;
		}

		html, body, table {
			font-family: -apple-system, BlinkMacSystemFont, "Segoe UI",
			"Roboto", "Oxygen", "Ubuntu", "Helvetica Neue", Arial, sans-serif;
		}

		@supports (font: -apple-system-body) {
			html, body, table {
				font: -apple-system-body !important;
			}
		}
		p {
			font-size: 1.0em;
			font-weight: normal;
		}

		body {
			color: white;
		}
		a:link {
			text-decoration: none;
			color: #0096e2;
		}
		a:visited {
			text-decoration: none;
			color: #9d57df;
		}
		"""

}
