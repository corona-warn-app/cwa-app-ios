// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

public enum ENAColor: String, CaseIterable {
	// MARK: - Background Colors
	case background = "ENA Background Color"
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
	static func enaColor(for style: ENAColor, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		switch style {
		case .background: return UIColor(rgb: 0xFFFFFF, alpha: 1.0)
		case .buttonPrimary: return UIColor(rgb: 0x007FAD, alpha: 1.0)
		case .buttonHighlight: return UIColor(rgb: 0x17191A, alpha: 0.1)
		case .listHighlight: return UIColor(rgb: 0x17191A, alpha: 0.2)
		case .separator: return UIColor(rgb: 0xF5F5F5, alpha: 1.0)
		case .textContrast: return UIColor(rgb: 0xFFFFFF, alpha: 1.0)
		case .textPrimary1: return UIColor(rgb: 0x17191A, alpha: 1.0)
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
