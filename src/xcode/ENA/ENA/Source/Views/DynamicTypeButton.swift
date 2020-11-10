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
class DynamicTypeButton: UIButton {
	@IBInspectable var cornerRadius: CGFloat = 8 { didSet { self.layer.cornerRadius = cornerRadius } }
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" { didSet { applyDynamicFont() } }

	private var rawFont: UIFont!

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	private func setup() {
		layer.cornerRadius = cornerRadius

		applyDynamicFont()
	}

	private func applyDynamicFont() {
		guard let titleLabel = self.titleLabel else { return }
		if rawFont == nil { rawFont = titleLabel.font }

		guard let textStyle = rawFont.textStyle else { return }

		titleLabel.adjustsFontForContentSizeCategory = true

		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil

		guard weight != nil || size != nil else { return }

		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)

		titleLabel.font = font
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		titleLabel?.sizeToFit()
	}
}
