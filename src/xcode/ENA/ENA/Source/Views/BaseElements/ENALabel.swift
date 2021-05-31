//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ENALabel: UILabel {

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

	var style: Style = .body { didSet { applyStyle() } }
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
				self.style = .body
				Log.error("Invalid text style set for \(String(describing: ENALabel.self)): \(ibEnaStyle)", log: .ui)
			}
		}
	}

	private var wasJustHighlighted: Bool = false

	private func fontForCurrentTextStyle(weight: UIFont.Weight? = nil) -> UIFont {
		let metrics = UIFontMetrics(forTextStyle: style.textStyle)
		let systemFont = UIFont.systemFont(ofSize: style.fontSize, weight: weight ?? UIFont.Weight(style.fontWeight))
		return metrics.scaledFont(for: systemFont)
	}
	
	private func applyStyle() {
		adjustsFontForContentSizeCategory = true
		applyHighlighting()
	}

	private func applyHighlighting() {
		// `wasJustHighlighted` is set to true if the `attributedText` was just set from this func.
		// Because setting `attributedText` automatically sets `text`, we need to make sure not to do the highlighting
		// again with the "**" markers already removed, which would result in loosing the highlighting again.
		guard !wasJustHighlighted else {
			wasJustHighlighted = true
			return
		}

		guard let text = text else {
			return
		}

		let components = text.components(separatedBy: "**")

		guard components.count > 1 else {
			self.font = fontForCurrentTextStyle()
			return
		}

		let sequence = components.enumerated()
		let attributedString = NSMutableAttributedString()

		wasJustHighlighted = true
		attributedText = sequence.reduce(into: attributedString) { string, pair in
			let isHighlighted = !pair.offset.isMultiple(of: 2)
			let font = fontForCurrentTextStyle(weight: isHighlighted ? style.highlightedWeight : style.nonHighlightedWeight)

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
		}
	}
}
