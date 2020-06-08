//
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
	static func enaFont(for style: ENAFont, textStyle: UIFont.TextStyle? = nil) -> UIFont {
		return UIFont
			.preferredFont(forTextStyle: style.textStyle)
			.scaledFont(size: style.fontSize, weight: style.fontWeight)
	}
}
