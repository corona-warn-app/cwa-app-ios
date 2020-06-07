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

	// MARK: - Attributes.
	var isTransparent = false
	var isInverted = false
	var color: UIColor?

	func configure() {
		setupView()
		applyStyle()
	}

	private func setupView() {
		// Style label.
		self.titleLabel?.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
		self.titleLabel?.adjustsFontForContentSizeCategory = true
		self.titleLabel?
			.lineBreakMode = .byWordWrapping

		// Style button.
		self.layer.cornerRadius = 8
		self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	}

	private func applyStyle() {
		let style: Style
		if isTransparent {
			style = .transparent
		} else if isInverted {
			style = .contrast
		} else {
			style = .emphasized(color: color)
		}

		if isEnabled {
			backgroundColor = style.backgroundColor
			setTitleColor(style.foregroundColor, for: .normal)
		} else {
			backgroundColor = style.disabledBackgroundColor
			setTitleColor(style.disabledForegroundColor.withAlphaComponent(0.5), for: .disabled)
		}
	}
}

private extension ENACloneButton {
	enum Style {
		case transparent
		case emphasized(color: UIColor?)
		case contrast
	}
}

private extension ENACloneButton.Style {
	var highlightColor: UIColor {
		.enaColor(for: .buttonHighlight)
	}

	var backgroundColor: UIColor {
		switch self {
		case .transparent: return .clear
		case .emphasized(let color): return color ?? .enaColor(for: .buttonPrimary)
		case .contrast: return .enaColor(for: .background)
		}
	}

	var foregroundColor: UIColor {
		switch self {
		case .transparent: return .enaColor(for: .textTint)
		case .emphasized: return .enaColor(for: .textContrast)
		case .contrast: return .enaColor(for: .textPrimary1)
		}
	}

	var disabledBackgroundColor: UIColor {
		switch self {
		case .transparent: return .clear
		case .emphasized: return .enaColor(for: .separator)
		case .contrast: return .enaColor(for: .separator)
		}
	}

	var disabledForegroundColor: UIColor {
		switch self {
		case .transparent: return .enaColor(for: .textTint)
		case .emphasized: return .enaColor(for: .textPrimary1)
		case .contrast: return .enaColor(for: .textPrimary1)
		}
	}
}
