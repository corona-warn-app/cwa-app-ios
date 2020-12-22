//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

protocol ENAButtonFooterViewDelegate: class {
	func footerView(_ footerView: UIView, didTapPrimaryButton button: UIButton)
	func footerView(_ footerView: UIView, didTapSecondaryButton button: UIButton)
}

extension ENAButtonFooterViewDelegate {
	func footerView(_ footerView: UIView, didTapPrimaryButton button: UIButton) {}
	func footerView(_ footerView: UIView, didTapSecondaryButton button: UIButton) {}
}

class ENANavigationFooterView: ENAFooterView {
	weak var delegate: ENAButtonFooterViewDelegate?

	var bottomInset: CGFloat {
		get { footerViewTopConstraint.constant }
		set { footerViewTopConstraint.constant = newValue }
	}
	private var footerViewTopConstraint: NSLayoutConstraint!

	private(set) var primaryButton: ENAButton!
	private(set) var secondaryButton: ENAButton!

	var primaryButtonTitle: String? {
		get { primaryButton.title(for: .normal) }
		set { primaryButton.setTitle(newValue, for: .normal) }
	}

	var secondaryButtonTitle: String? {
		get { secondaryButton.title(for: .normal) }
		set { secondaryButton.setTitle(newValue, for: .normal) }
	}

	var isPrimaryButtonHidden: Bool {
		get { primaryButton.alpha < 0.1 }
		set { primaryButton.alpha = newValue ? 0 : 1 }
	}

	var isSecondaryButtonHidden: Bool {
		get { secondaryButton.alpha < 0.1 }
		set { secondaryButton.alpha = newValue ? 0 : 1 }
	}

	var isPrimaryButtonEnabled: Bool {
		get { primaryButton.isEnabled }
		set { primaryButton.isEnabled = newValue }
	}

	var isSecondaryButtonEnabled: Bool {
		get { secondaryButton.isEnabled }
		set { secondaryButton.isEnabled = newValue }
	}

	var isPrimaryButtonLoading: Bool {
		get { primaryButton.isLoading }
		set { primaryButton.isLoading = newValue }
	}

	var isSecondaryButtonLoading: Bool {
		get { secondaryButton.isLoading }
		set { secondaryButton.isLoading = newValue }
	}

	var secondaryButtonHasBorder: Bool {
		get { secondaryButton.hasBorder }
		set { secondaryButton.hasBorder = newValue }
	}
	
	var secondaryButtonHasBackground: Bool {
		get { secondaryButton.hasBackground }
		set { secondaryButton.hasBackground = newValue }
	}
	

	private let spacing: CGFloat = 8

	convenience init() {
		self.init(effect: nil)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(effect: UIVisualEffect?) {
		super.init(effect: effect)
		setup()
	}
}

extension ENANavigationFooterView {
	override func didMoveToSuperview() {
		super.didMoveToSuperview()

		translatesAutoresizingMaskIntoConstraints = false

		if let superview = superview {
			superview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			superview.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
			superview.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

			footerViewTopConstraint = superview.bottomAnchor.constraint(equalTo: self.topAnchor)
			footerViewTopConstraint?.isActive = true
		}
	}
}

extension ENANavigationFooterView {
	private func setup() {
		setupPrimaryButton()
		setupSecondaryButton()

		contentView.insetsLayoutMarginsFromSafeArea = false
		contentView.preservesSuperviewLayoutMargins = false
		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		contentView.addSubview(primaryButton)
		contentView.addSubview(secondaryButton)

		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		primaryButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
		primaryButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
		primaryButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true

		secondaryButton.translatesAutoresizingMaskIntoConstraints = false
		secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: spacing).isActive = true
		secondaryButton.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor).isActive = true
		secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor).isActive = true
	}

	private func setupPrimaryButton() {
		primaryButton = ENAButton(type: .custom)
		primaryButton.setTitle("Primary Button", for: .normal)
		primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .primaryActionTriggered)
		primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.primaryFooterButton
	}

	private func setupSecondaryButton() {
		secondaryButton = ENAButton(type: .custom)
		secondaryButton.setTitle("Secondary Button", for: .normal)
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.secondaryFooterButton
	}
}

extension ENANavigationFooterView {
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		var height: CGFloat = contentView.layoutMargins.top + contentView.layoutMargins.bottom

		if !isPrimaryButtonHidden {
			let primaryButtonSize = primaryButton.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
			height += primaryButtonSize.height
		}

		if !isSecondaryButtonHidden {
			let secondaryButtonSize = secondaryButton.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
			height += secondaryButtonSize.height
		}

		if  !isPrimaryButtonHidden && !isSecondaryButtonHidden {
			height += spacing
		}

		return CGSize(width: size.width, height: height)
	}
}

extension ENANavigationFooterView {
	func apply(navigationItem: UINavigationItem?) {
		if let navigationItem = navigationItem as? ENANavigationFooterItem {
			isPrimaryButtonHidden = navigationItem.isPrimaryButtonHidden
			isPrimaryButtonEnabled = navigationItem.isPrimaryButtonEnabled
			isPrimaryButtonLoading = navigationItem.isPrimaryButtonLoading
			if !isPrimaryButtonHidden { primaryButtonTitle = navigationItem.primaryButtonTitle }

			isSecondaryButtonHidden = navigationItem.isSecondaryButtonHidden
			isSecondaryButtonEnabled = navigationItem.isSecondaryButtonEnabled
			isSecondaryButtonLoading = navigationItem.isSecondaryButtonLoading
			secondaryButtonHasBorder = navigationItem.secondaryButtonHasBorder
			secondaryButtonHasBackground = navigationItem.secondaryButtonHasBackground
			if !isSecondaryButtonHidden { secondaryButtonTitle = navigationItem.secondaryButtonTitle }
			
		} else {
			isPrimaryButtonHidden = true
			isPrimaryButtonEnabled = false
			isPrimaryButtonLoading = false
			if !isPrimaryButtonHidden { primaryButtonTitle = nil }

			isSecondaryButtonHidden = true
			isSecondaryButtonEnabled = false
			isSecondaryButtonLoading = false
			secondaryButtonHasBorder = false
			secondaryButtonHasBackground = false
			if !isSecondaryButtonHidden { secondaryButtonTitle = nil }
		}
	}
}

private extension ENANavigationFooterView {
	@objc
	private func didTapPrimaryButton() {
		delegate?.footerView(self, didTapPrimaryButton: primaryButton)
	}

	@objc
	private func didTapSecondaryButton() {
		delegate?.footerView(self, didTapSecondaryButton: secondaryButton)
	}
}
