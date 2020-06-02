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

public enum ColorStyle: String {
	case backgroundPrimary = "background"
	case backgroundSecondary = "backgroundGroup"

	case brandRed
	case brandBlue
	case brandMagenta

	case separator
	case hairline
	case hairlineContrast
	case tint

	case textPrimary1
	case textPrimary2
	case textPrimary3

	case positiveRisk = "positive"
	case negativeRisk = "negative"
	case inactiveRisk = "medium"
	case unknownRisk = "unknown"

	// TODO: Colors not defined by design
	case chevron
	case shadow
}

public extension UIColor {
	convenience init?(style: ColorStyle, interface: UIUserInterfaceStyle = .unspecified) {
		if interface == .unspecified {
			self.init(named: style.rawValue)
		} else {
			self.init(named: style.rawValue, in: nil, compatibleWith: UITraitCollection(userInterfaceStyle: interface))
		}
	}


	#if TARGET_INTERFACE_BUILDER
	static func preferredColor(for style: ColorStyle, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		switch style {
		case .tint: return UIColor(red: 0 / 255.0, green: 127 / 255.0, blue: 173 / 255.0, alpha: 1)
		case .separator: return UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1)
		case .textPrimary1: return UIColor(red: 23 / 255.0, green: 25 / 255.0, blue: 26 / 255.0, alpha: 1)
		case .backgroundPrimary: return UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1)
		default:
			fatalError("Requested color is not available in interface builder: " + style.rawValue)
		}
	}
	#else
	static func preferredColor(for style: ColorStyle, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		if let color = UIColor(style: style, interface: interface) {
			return color
		} else {
			fatalError("Requested color is not available: " + style.rawValue)
		}
	}
	#endif
}
