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

/// A simplified clone of the ENAButton. Note that this introduces code duplication and should only be considered a temporary fix.
class ENACloneButton: UIButton {
	// MARK: Creating a ENA Button
	init() {
		super.init(frame: .zero)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		// disabled state
		setBackgroundImage(.filled(with: .white), for: .disabled)
		setTitleColor(UIColor.enaColor(for: .textPrimary1).withAlphaComponent(0.3), for: .disabled)

		// normal state
		setBackgroundImage(.filled(with: .white), for: .normal)
		setTitleColor(.enaColor(for: .textPrimary1), for: .normal)

		// Title & Corners
		titleLabel?.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
		titleLabel?.adjustsFontForContentSizeCategory = true
		titleLabel?
			.lineBreakMode = .byWordWrapping

		// Style button.
		clipsToBounds = true
		layer.cornerRadius = 8
		layer.maskedCorners = [
			.layerMinXMinYCorner,
			.layerMinXMaxYCorner,
			.layerMaxXMinYCorner,
			.layerMaxXMaxYCorner
		]
		contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	}
}

private extension UIImage {
	class func filled(with color: UIColor) -> UIImage {
		let size = CGSize(width: 1.0, height: 1.0)
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { context in
			color.setFill()
			context.fill(.init(origin: .zero, size: size))
		}
	}
}
