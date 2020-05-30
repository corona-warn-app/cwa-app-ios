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
	
	 // TODO Colors not defined by design
	case chevron
	case shadow
}

extension UIColor {
	convenience init?(style: ColorStyle, interface: UIUserInterfaceStyle = .unspecified) {
		if interface == .unspecified {
			self.init(named: style.rawValue)
		} else {
			self.init(named: style.rawValue, in: nil, compatibleWith: UITraitCollection(userInterfaceStyle: interface))
		}
	}
	
	static func preferredColor(for style: ColorStyle, interface: UIUserInterfaceStyle = .unspecified) -> UIColor {
		if let color = UIColor(style: style, interface: interface) {
			return color
		} else {
			fatalError("Requested color is not available: " + style.rawValue)
		}
	}
}
