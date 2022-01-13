//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ENALinkedTextView: UITextView {
	
	struct Link {
		let text: String
		let link: String
	}
	
	// MARK: - Init

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		
		backgroundColor = .clear

		translatesAutoresizingMaskIntoConstraints = false
		isScrollEnabled = false
		isEditable = false
		// The two below settings make the UITextView look more like a UILabel
		// By default, UITextView has some insets & padding that differ from a UILabel.
		// For example, there are insets different from UILabel that cause the text to be a little offset
		// at all sides when compared to a UILabel.
		// As this cell is used together with regular UILabel-backed cells in the same table,
		// we want to ensure that our text view looks exactly like the label-backed cells.
		textContainerInset = .zero
		self.textContainer.lineFragmentPadding = .zero
		delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal

	func configure(
		text: String,
		textFont: ENAFont,
		textColor: UIColor,
		links: [Link],
		tintColor: UIColor = .enaColor(for: .textTint),
		linkColor: UIColor
	) {
		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(
				forTextStyle: textFont.textStyle
			).scaledFont(
				size: textFont.fontSize,
				weight: textFont.fontWeight
			),
			.foregroundColor: textColor
		]
		let attributedText = NSMutableAttributedString(
			string: text,
			attributes: textAttributes
		)
		links.forEach {
			attributedText.mark($0.text, with: $0.link)
		}
		self.attributedText = attributedText
		
		// setup link style - only available in UITextView
		linkTextAttributes = [
			.foregroundColor: linkColor,
			.underlineColor: UIColor.clear
		]
		
		self.tintColor = tintColor
	}
	
}

// MARK: - Protocol UITextViewDelegate

extension ENALinkedTextView: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
}
