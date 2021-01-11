//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

@IBDesignable
class ENAButton: DynamicTypeButton {
	@IBInspectable var color: UIColor?

	@IBInspectable var hasBackground: Bool = true { didSet { applyStyle() } }
	@IBInspectable var isInverted: Bool = false { didSet { applyStyle() } }
	@IBInspectable var isLoading: Bool = false { didSet { applyStyle() } }
	@IBInspectable var hasBorder: Bool = false { didSet {
		applyStyle()

	} }

	override var isEnabled: Bool { didSet { applyStyle() } }
	override var isHighlighted: Bool { didSet { applyHighlight() } }

	private var highlightView: UIView!
	private weak var activityIndicator: UIActivityIndicatorView?

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

		titleLabel?.font = .preferredFont(forTextStyle: .body)
		titleLabel?.textAlignment = .center
		titleLabel?.lineBreakMode = .byWordWrapping
		dynamicTypeSize = 17
		dynamicTypeWeight = "semibold"

		// Important: Must be added after accessing title label for the first time for correct z-order.
		highlightView?.removeFromSuperview()
		highlightView = UIView(frame: bounds)
		highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(highlightView)

		applyStyle()
		applyHighlight()
		applySizeConstraint()
	}

	private func applySizeConstraint() {
		let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
		heightConstraint.priority = .defaultHigh
		heightConstraint.isActive = true

		if let titleLabel = titleLabel {
			widthAnchor.constraint(greaterThanOrEqualTo: titleLabel.widthAnchor, constant: contentEdgeInsets.left + contentEdgeInsets.right).isActive = true
			heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: contentEdgeInsets.top + contentEdgeInsets.bottom).isActive = true
		}
	}

	private func applyStyle() {
		let style: Style
		if !hasBackground {
			style = .transparent
		} else if isInverted {
			style = .contrast
		} else {
			style = .emphasized(color: color)
		}

		applyActivityIndicator()

		if isEnabled {
			backgroundColor = style.backgroundColor
			setTitleColor(style.foregroundColor, for: .normal)
			activityIndicator?.color = style.foregroundColor
		} else {
			backgroundColor = style.disabledBackgroundColor
			setTitleColor(style.disabledForegroundColor.withAlphaComponent(0.5), for: .disabled)
			activityIndicator?.color = style.disabledForegroundColor.withAlphaComponent(0.5)
		}

		if hasBorder {
			layer.borderWidth = 1
			layer.borderColor = style.foregroundColor.cgColor
			layer.cornerRadius = 8
		} else {
			layer.borderWidth = 0
		}

		highlightView?.backgroundColor = style.highlightColor
	}

	private func applyHighlight() {
		highlightView.isHidden = !isHighlighted
	}

	private func applyActivityIndicator() {
		guard isLoading else {
			activityIndicator?.removeFromSuperview()
			titleLabel?.invalidateIntrinsicContentSize()
			return
		}

		guard nil == activityIndicator else { return }

		let activityIndicator: UIActivityIndicatorView
		if #available(iOS 13.0, *) {
			activityIndicator = UIActivityIndicatorView(style: traitCollection.preferredContentSizeCategory >= .accessibilityExtraLarge ? .large : .medium)
		} else {
			activityIndicator = UIActivityIndicatorView(style: traitCollection.preferredContentSizeCategory >= .accessibilityExtraLarge ? .whiteLarge : .white)
		}
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.isUserInteractionEnabled = false

		addSubview(activityIndicator)

		if let title = titleLabel {
			title.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 8).isActive = true
			activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 8).isActive = true
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		} else {
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
			activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 8).isActive = true
			self.trailingAnchor.constraint(greaterThanOrEqualTo: activityIndicator.trailingAnchor, constant: 8).isActive = true
		}

		updateActivityIndicatorStyle()

		activityIndicator.startAnimating()

		self.activityIndicator = activityIndicator

		UIView.performWithoutAnimation {
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}
	}

	private func updateActivityIndicatorStyle() {
		if traitCollection.preferredContentSizeCategory >= .accessibilityExtraLarge {
			if #available(iOS 13.0, *) {
				activityIndicator?.style = .large
			} else {
				activityIndicator?.style = .whiteLarge
			}
		} else {
			if #available(iOS 13.0, *) {
				activityIndicator?.style = .medium
			} else {
				activityIndicator?.style = .white
			}
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateActivityIndicatorStyle()
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
