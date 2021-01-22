//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ENALabel: DynamicTypeLabel {

	// MARK: - Init

	// MARK: - Overrides

	override func prepareForInterfaceBuilder() {
		self.applyStyle()
		super.prepareForInterfaceBuilder()
	}

	override func awakeFromNib() {
		self.applyStyle()
		super.awakeFromNib()
	}

	override func accessibilityElementDidBecomeFocused() {
		super.accessibilityElementDidBecomeFocused()

		onAccessibilityFocus?()
	}

	// MARK: - Public

	// MARK: - Internal

	var style: Style = .body { didSet { applyStyle() } }
	var onAccessibilityFocus: (() -> Void)?

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
	
	private func applyStyle() {
		self.font = UIFont.preferredFont(forTextStyle: self.style.textStyle)
		self.dynamicTypeSize = self.style.fontSize
		self.dynamicTypeWeight = self.style.fontWeight
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
