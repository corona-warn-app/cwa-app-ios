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

extension UIFont {
	var textStyle: UIFont.TextStyle? {
		guard let string = fontDescriptor.fontAttributes[.textStyle] as? String else { return nil }
		return UIFont.TextStyle(rawValue: string)
	}

	func scaledFont(size: CGFloat? = nil, weight: Weight? = .regular) -> UIFont {
		guard let textStyle = self.textStyle else { return self }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: weight ?? .regular)
		let font = metrics.scaledFont(for: systemFont)

		return font
	}
}

extension UIFont.Weight {
	init(_ string: String?) {
		let weights: [String: UIFont.Weight] = [
			"ultraLight": .ultraLight,
			"thin": .thin,
			"light": .light,
			"regular": .regular,
			"medium": .medium,
			"semibold": .semibold,
			"bold": .bold,
			"heavy": .heavy,
			"black": .black
		]
		self.init(rawValue: weights[string ?? "regular"]?.rawValue ?? UIFont.Weight.regular.rawValue)
	}
}
