//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum ENAFont: String {
	case title1
	case title2
	case headline
	case body
	case subheadline
	case footnote
}

extension ENAFont {
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

	var fontWeight: UIFont.Weight {
		switch self {
		case .title1: return .bold
		case .title2: return .bold
		case .headline: return .semibold
		case .body: return .regular
		case .subheadline: return .regular
		case .footnote: return .regular
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

extension UIFont {
	static func enaFont(for style: ENAFont, weight: UIFont.Weight? = nil, italic: Bool = false) -> UIFont {
		return UIFont
			.preferredFont(forTextStyle: style.textStyle)
			.scaledFont(size: style.fontSize, weight: weight ?? style.fontWeight, italic: italic)
	}
}
