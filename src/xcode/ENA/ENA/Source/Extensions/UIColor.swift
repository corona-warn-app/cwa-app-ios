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

extension UIColor {
	public class func preferredColor(for style: ColorStyle, variant _: UIUserInterfaceStyle = .light) -> UIColor {
		if let color = preferredColorVariant(for: style) {
			return color
		} else {
			fatalError("Requested color is not available.")
		}
	}

	// swiftlint:disable:next cyclomatic_complexity
	private class func preferredColorVariant(for style: ColorStyle) -> UIColor? {
		switch style {
		case .textPrimary1:
			return UIColor(named: "textPrimary1")
		case .textPrimary2:
			return UIColor(named: "textPrimary2")
		case .textPrimary3:
			return UIColor(named: "textPrimary3")
		case .tintColor:
			return UIColor(red: 0.00, green: 0.53, blue: 0.70, alpha: 1.00)
		case .separator:
			return UIColor(named: "separator")
		case .hairline:
			return UIColor(named: "hairline")
		case .backgroundBase:
			return UIColor(named: "background")
		case .backgroundContrast:
			return UIColor(named: "backgroundGroup")
		case .chevron:
			return UIColor(named: "chevron")
		case .positive:
			return UIColor(named: "positive")
		case .negative:
			return UIColor(named: "negative")
		case .inactive:
			return UIColor(named: "medium")
		case .unknownRisk:
			return UIColor(named: "unknown")
		case .brandRed:
			return UIColor(named: "brandRed")
		case .brandBlue:
			return UIColor(named: "brandBlue")
		case .brandMagenta:
			return UIColor(named: "brandMagenta")
		case .shadow:
			return UIColor(named: "shadow")
		}
	}

	func renderImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
		UIGraphicsImageRenderer(size: size).image { rendererContext in
			setFill()
			rendererContext.fill(CGRect(origin: .zero, size: size))
		}
	}
}
