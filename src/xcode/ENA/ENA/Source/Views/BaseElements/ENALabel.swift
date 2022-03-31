//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ENALabel: UILabel {

	// MARK: - Init

	convenience init(style: Style = .body) {
		self.init()
		self.style = style
		applyStyle()
	}

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		self.applyStyle()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		self.applyStyle()
	}

	override func accessibilityElementDidBecomeFocused() {
		super.accessibilityElementDidBecomeFocused()

		onAccessibilityFocus?()
	}

	// MARK: - Internal

	var style: Style? {
		didSet {
			applyStyle()
		}
	}
	var onAccessibilityFocus: (() -> Void)?

	override var text: String? {
		didSet {
			applyHighlighting()
		}
	}

	// MARK: - Private

	@IBInspectable private var ibEnaStyle: String = "body" {
		didSet {
			if let style = Style(rawValue: ibEnaStyle) {
				self.style = style
			} else {
				Log.error("Invalid text style set for \(String(describing: ENALabel.self)): \(ibEnaStyle)", log: .ui)
			}
		}
	}

	private func fontForStyle(_ style: Style, weight: UIFont.Weight? = nil) -> UIFont {
		let metrics = UIFontMetrics(forTextStyle: style.textStyle)
		let systemFont = UIFont.systemFont(ofSize: style.fontSize, weight: weight ?? UIFont.Weight(style.fontWeight))
		return metrics.scaledFont(for: systemFont)
	}
	
	private func applyStyle() {
		adjustsFontForContentSizeCategory = true
		applyHighlighting()
	}

	private func applyHighlighting() {
		guard let text = text, let style = style else {
			return
		}

		let components = text.components(separatedBy: "**")

		guard components.count > 1 else {
			self.font = fontForStyle(style)
			return
		}

		let sequence = components.enumerated()
		let attributedString = NSMutableAttributedString()

		attributedText = sequence.reduce(into: attributedString) { string, pair in
			let isHighlighted = !pair.offset.isMultiple(of: 2)
			let font = fontForStyle(style, weight: isHighlighted ? style.highlightedWeight : style.nonHighlightedWeight)

			string.append(NSAttributedString(
				string: pair.element,
				attributes: [.font: font]
			))
		}
	}
	
}

extension ENALabel {
	enum Style: String {
		case title1
		case title2
		case headline
		case body
		case subheadline
		case footnote
		case badge
	}
}

extension ENALabel.Style {

	var fontSize: CGFloat {
		switch self {
		case .title1: return 28
		case .title2: return 22
		case .headline: return 17
		case .body: return 17
		case .subheadline: return 15
		case .footnote: return 13
		case .badge: return 10
		}
	}
	
	var fontWeight: String {
		switch self {
		case .title1: return "bold"
		case .title2: return "bold"
		case .headline: return "semibold"
		case .body: return "regular"
		case .subheadline: return "regular"
		case .footnote: return "regular"
		case .badge: return "bold"
		}
	}
	
	var textStyle: UIFont.TextStyle {
		switch self {
		case .title1: return .largeTitle
		case .title2: return .title2
		case .headline: return .headline
		case .body: return .body
		case .subheadline: return .subheadline
		case .footnote: return .footnote
		case .badge: return .caption1
		}
	}

	var nonHighlightedWeight: UIFont.Weight {
		switch self {
		case .title1: return .light
		case .title2: return .light
		case .headline: return .light
		case .body: return .regular
		case .subheadline: return .regular
		case .footnote: return .regular
		case .badge: return .light
		}
	}

	var highlightedWeight: UIFont.Weight {
		switch self {
		case .title1: return .bold
		case .title2: return .bold
		case .headline: return .semibold
		case .body: return .bold
		case .subheadline: return .bold
		case .footnote: return .bold
		case .badge: return .bold
		}
	}

}


extension ENAFont {
	var labelStyle: ENALabel.Style {
		switch self {
		case .title1: return .title1
		case .title2: return .title2
		case .headline: return .headline
		case .body: return .body
		case .subheadline: return .subheadline
		case .footnote: return .footnote
		case .badge: return .badge
		}
	}
}
