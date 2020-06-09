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

@IBDesignable
class DynamicTypeSymbolImageView: UIImageView {
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applySymbolConfiguration() } }
	@IBInspectable var dynamicTypeWeight: String = "" { didSet { applySymbolConfiguration() } }

	private var scaledPointSize: CGFloat {
		let font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: dynamicTypeSize)
		return font.pointSize
	}

	private var isSettingImageInternally: Bool = false

	override var image: UIImage? { didSet { applySymbolConfiguration() } }

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applySymbolConfiguration()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		applySymbolConfiguration()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		applySymbolConfiguration()
	}

	private func applySymbolConfiguration() {
		guard !isSettingImageInternally else { return }
		isSettingImageInternally = true

		let weight = UIImage.SymbolWeight(dynamicTypeWeight) ?? .regular
		let configuration = UIImage.SymbolConfiguration(pointSize: scaledPointSize, weight: weight, scale: .default)
		image = image?.withConfiguration(configuration)

		isSettingImageInternally = false
	}
}

private extension UIImage.SymbolWeight {
	init?(_ string: String) {
		switch string {
		case "thin": self = .thin
		case "light": self = .light
		case "regular": self = .regular
		case "semibold": self = .semibold
		case "medium": self = .medium
		case "bold": self = .bold
		case "heavy": self = .heavy
		case "black": self = .black
		default: return nil
		}
	}
}
