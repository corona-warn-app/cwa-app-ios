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
class ENAButton: DynamicTypeButton {
	@IBInspectable var color: UIColor?

	@IBInspectable var isTransparent: Bool = false { didSet { applyStyle() } }
	@IBInspectable var isInverted: Bool = false { didSet { applyStyle() } }

	override var isEnabled: Bool { didSet { applyStyle() } }
	override var isHighlighted: Bool { didSet { applyHighlight() } }

	private var highlightView: UIView!

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		if size.height < 50 { size.height = 50 }
		return size
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}


	override func prepareForInterfaceBuilder() {
		setup()
		super.prepareForInterfaceBuilder()
	}


	override func awakeFromNib() {
		setup()
		super.awakeFromNib()
	}

	private func setup() {
		setValue(ButtonType.custom.rawValue, forKey: "buttonType")

		clipsToBounds = true

		contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

		highlightView?.removeFromSuperview()
		highlightView = UIView(frame: bounds)
		highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(highlightView)

		titleLabel?.font = .preferredFont(forTextStyle: .body)
		cornerRadius = 8
		dynamicTypeSize = 17
		dynamicTypeWeight = "semibold"

		applyStyle()
		applyHighlight()
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

		highlightView?.backgroundColor = style.highlightColor
	}

	private func applyHighlight() {
		highlightView.isHidden = !isHighlighted
	}
}

private extension ENAButton {
	enum Style {
		case transparent
		case emphasized(color: UIColor?)
		case contrast
	}
}

extension ENAButton.Style {
	var highlightColor: UIColor {
		UIColor.black.withAlphaComponent(0.2)
	}

	var backgroundColor: UIColor {
		switch self {
		case .transparent: return .clear
		case .emphasized(let color): return color ?? .preferredColor(for: .tint)
		case .contrast: return .preferredColor(for: .backgroundPrimary)
		}
	}

	var foregroundColor: UIColor {
		switch self {
		case .transparent: return .preferredColor(for: .tint)
		case .emphasized: return .white
		case .contrast: return .preferredColor(for: .textPrimary1, interface: .dark)
		}
	}

	var disabledBackgroundColor: UIColor {
		switch self {
		case .transparent: return .preferredColor(for: .separator)
		case .emphasized: return .preferredColor(for: .separator)
		case .contrast: return .preferredColor(for: .separator)
		}
	}

	var disabledForegroundColor: UIColor {
		switch self {
		case .transparent: return .preferredColor(for: .tint)
		case .emphasized: return .preferredColor(for: .textPrimary1)
		case .contrast: return .preferredColor(for: .textPrimary1)
		}
	}
}
