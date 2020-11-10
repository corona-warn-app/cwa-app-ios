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

@IBDesignable
class DynamicTypeLabel: UILabel {
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" {
		didSet { applyDynamicFont() }
	}

	private var rawFont: UIFont!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyDynamicFont()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		applyDynamicFont()
	}

	private func applyDynamicFont() {
		if rawFont == nil { rawFont = self.font }

		guard let textStyle = rawFont.textStyle else { return }

		adjustsFontForContentSizeCategory = true

		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil

		guard weight != nil || size != nil else { return }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)

		self.font = font
	}
}
