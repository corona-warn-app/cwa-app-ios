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
	@IBInspectable var isLoading: Bool = false { didSet { isEnabled = !isLoading } }

	override var isEnabled: Bool { didSet { applyStyle() } }
	override var isHighlighted: Bool { didSet { applyHighlight() } }

	private var highlightView: UIView!
	private var activityIndicator: UIActivityIndicatorView!

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
		cornerRadius = 8

		contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
		// TODO temporary fix for auto layout warnings on home screen
		heightConstraint.priority = .init(999)
		heightConstraint.isActive = true

		titleLabel?.font = .preferredFont(forTextStyle: .body)
		dynamicTypeSize = 17
		dynamicTypeWeight = "semibold"

		// Important: Must be added after accessing title label for the first time for correct z-order.
		highlightView?.removeFromSuperview()
		highlightView = UIView(frame: bounds)
		highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(highlightView)

		// MARK: - Add spinner for loading state.
		activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.isUserInteractionEnabled = false
		addSubview(activityIndicator)
		if let title = titleLabel {
			activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8).isActive = true
			title.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 8).isActive = true
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
			activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8).isActive = true
			trailingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 8).isActive = true
		} else {
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		}

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

		if isLoading && isEnabled {
			activityIndicator.color = style.foregroundColor
			activityIndicator.startAnimating()
		} else if isLoading && !isEnabled {
			activityIndicator.color = style.disabledForegroundColor.withAlphaComponent(0.5)
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
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
