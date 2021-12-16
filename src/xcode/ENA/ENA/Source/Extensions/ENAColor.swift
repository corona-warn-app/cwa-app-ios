//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

public enum ENAColor: String, CaseIterable {
	// MARK: - Background Colors
	case background = "ENA Background Color"
	case backgroundLightGray = "ENA Background Light Gray Color"
	case darkBackground = "ENA Dark Background Color"
	case cellBackground = "ENA Cell Background Color"
	case cellBackground2 = "ENA Cell Background Color 2"
	case cellBackground3 = "ENA Cell Background Color 3"
	case hairline = "ENA Hairline Color"
	case hairlineContrast = "ENA Hairline Contrast Color"
	case separator = "ENA Separator Color"

	// MARK: - Brand Colors
	case brandBlue = "ENA Brand Blue Color"
	case brandBurgundy = "ENA Brand Burgundy Color"
	case brandRed = "ENA Brand Red Color"

	// MARK: - Button Colors
	case buttonDestructive = "ENA Button Destructive Color"
	case buttonHighlight = "ENA Button Highlight Color"
	case buttonPrimary = "ENA Button Primary Color"
	case selectedSegmentTint = "ENA Selected Segment Tint Color"

	// MARK: - Card Colors
	case dashedCardBorder = "ENA Dashed Card Border Color"
	case cardBorder = "ENA Card Border Color"
	case cardShadow = "ENA Card Shadow Color"

	// MARK: - Miscellaneous Colors
	case chevron = "ENA Chevron Color"
	case shadow = "ENA Shadow Color"
	case tint = "ENA Tint Color"

	// MARK: - Risk Colors
	case riskHigh = "ENA Risk High Color"
	case riskLow = "ENA Risk Low Color"
	case riskMedium = "ENA Risk Medium Color"
	case riskNeutral = "ENA Risk Neutral Color"

	// MARK: - Tap States Colors
	case listHighlight = "ENA List Highlight Color"

	// MARK: - Text Colors
	case textContrast = "ENA Text Contrast Color"
	case textPrimary1 = "ENA Text Primary 1 Color"
	case textPrimary1Contrast = "ENA Text Primary 1 Contrast Color"
	case textPrimary2 = "ENA Text Primary 2 Color"
	case textPrimary3 = "ENA Text Primary 3 Color"
	case textSemanticGray = "ENA Text Semantic Gray Color"
	case textSemanticGreen = "ENA Text Semantic Green Color"
	case textSemanticRed = "ENA Text Semantic Red Color"
	case textTint = "ENA Text Tint Color"
	case iconWithText = "IconWithText"

	// MARK: - Textfield
	case textField = "ENA Textfield Color"

	// MARK: - Certificate-PDF
	case certificatePDFBlue = "Certificate-PDF Blue"

}

public extension UIColor {
	convenience init?(enaColor style: ENAColor, interface: UIUserInterfaceStyle = .unspecified) {
		if interface == .unspecified {
			self.init(named: style.rawValue)
		} else {
			self.init(named: style.rawValue, in: nil, compatibleWith: UITraitCollection(userInterfaceStyle: interface))
		}
	}

	#if TARGET_INTERFACE_BUILDER
	// swiftlint:disable:next cyclomatic_complexity
	static func enaColor(for style: ENAColor, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		switch style {
		case .background: return UIColor(rgb: 0xFFFFFF, alpha: 1.0)
		case .backgroundLightGray: return UIColor(rgb: 0xF8F8F8, alpha: 1.0)
		case .buttonPrimary: return UIColor(rgb: 0x007FAD, alpha: 1.0)
		case .buttonHighlight: return UIColor(rgb: 0x17191A, alpha: 0.1)
		case .listHighlight: return UIColor(rgb: 0x17191A, alpha: 0.2)
		case .separator: return UIColor(rgb: 0xF5F5F5, alpha: 1.0)
		case .textContrast: return UIColor(rgb: 0xFFFFFF, alpha: 1.0)
		case .textPrimary1: return UIColor(rgb: 0x17191A, alpha: 1.0)
		case .textSemanticRed: return UIColor(rgb: 0xC00F2D, alpha: 1.0)
		case .textSemanticGray: return UIColor(rgb: 0x5D6E80, alpha: 1.0)
		case .textTint: return UIColor(rgb: 0x007FAD, alpha: 1.0)
		case .tint: return UIColor(rgb: 0x007FAD, alpha: 1.0)
		default:
			fatalError("Requested color is not available in interface builder: " + style.rawValue)
		}
	}
	#else
	static func enaColor(for style: ENAColor, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		if let color = UIColor(enaColor: style, interface: interface) {
			return color
		} else {
			fatalError("Requested color is not available: " + style.rawValue)
		}
	}
	#endif
}

private extension UIColor {
	convenience init(rgb: UInt32, alpha: CGFloat) {
		self.init(
			red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
			green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
			blue: CGFloat(rgb & 0xFF) / 255.0,
			alpha: alpha
		)
	}
}
