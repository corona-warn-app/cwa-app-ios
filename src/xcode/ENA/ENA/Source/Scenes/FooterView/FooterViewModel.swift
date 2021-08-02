////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class FooterViewModel {

	// MARK: - Init
	
	init(
		primaryButtonName: String,
		secondaryButtonName: String? = nil,
		primaryIdentifier: String = AccessibilityIdentifiers.General.primaryFooterButton,
		secondaryIdentifier: String = AccessibilityIdentifiers.General.secondaryFooterButton,
		isPrimaryButtonEnabled: Bool = true,
		isSecondaryButtonEnabled: Bool = true,
		isPrimaryButtonHidden: Bool = false,
		isSecondaryButtonHidden: Bool = false,
		primaryButtonColor: UIColor = .enaColor(for: .buttonPrimary),
		secondaryButtonColor: UIColor = .enaColor(for: .buttonPrimary),
		primaryCustomDisableBackgroundColor: UIColor? = nil,
		secondaryCustomDisableBackgroundColor: UIColor? = nil,
		primaryButtonInverted: Bool = false,
		secondaryButtonInverted: Bool = false,
		backgroundColor: UIColor = .enaColor(for: .background),
		primaryTextColor: UIColor? = nil,
		secondaryTextColor: UIColor? = nil
	) {
		self.primaryButtonName = primaryButtonName
		self.secondaryButtonName = secondaryButtonName
		self.primaryIdentifier = primaryIdentifier
		self.secondaryIdentifier = secondaryIdentifier
		self.isPrimaryButtonEnabled = isPrimaryButtonEnabled
		self.isSecondaryButtonEnabled = isSecondaryButtonEnabled
		self.isPrimaryButtonHidden = isPrimaryButtonHidden
		self.isSecondaryButtonHidden = isSecondaryButtonHidden
		self.primaryButtonColor = primaryButtonColor
		self.secondaryButtonColor = secondaryButtonColor
		self.primaryCustomDisableBackgroundColor = primaryCustomDisableBackgroundColor
		self.secondaryCustomDisableBackgroundColor = secondaryCustomDisableBackgroundColor
		self.primaryButtonInverted = primaryButtonInverted
		self.secondaryButtonInverted = secondaryButtonInverted
		self.backgroundColor = backgroundColor
		self.primaryTextColor = primaryTextColor
		self.secondaryTextColor = secondaryTextColor
	}

	// MARK: - Internal

	// state where primary is hidden and secondary is show not supported at the moment
	enum VisibleButtons {
		case both
		case primary
		case none
	}

	enum ButtonType {
		case primary
		case secondary
	}

	let buttonHeight: CGFloat = 50.0
	let spacer: CGFloat = 8.0
	let topBottomInset: CGFloat = 16.0
	let leftRightInset: CGFloat = 16.0
	let primaryButtonColor: UIColor?
	let secondaryButtonColor: UIColor?
	let primaryCustomDisableBackgroundColor: UIColor?
	let secondaryCustomDisableBackgroundColor: UIColor?
	let primaryButtonInverted: Bool
	let secondaryButtonInverted: Bool
	let primaryIdentifier: String
	let secondaryIdentifier: String
	let primaryTextColor: UIColor?
	let secondaryTextColor: UIColor?

	@OpenCombine.Published private(set) var isPrimaryButtonHidden: Bool
	@OpenCombine.Published private(set) var isSecondaryButtonHidden: Bool

	@OpenCombine.Published private(set) var isPrimaryLoading: Bool = false
	@OpenCombine.Published private(set) var isSecondaryLoading: Bool = false
	@OpenCombine.Published private(set) var isPrimaryButtonEnabled: Bool
	@OpenCombine.Published private(set) var isSecondaryButtonEnabled: Bool

	var primaryButtonName: String?
	var secondaryButtonName: String?

	@OpenCombine.Published var backgroundColor: UIColor?

	func update(to state: VisibleButtons) {
		switch state {
		case .both:
			self.isPrimaryButtonHidden = false
			self.isSecondaryButtonHidden = false
		case .primary:
			self.isPrimaryButtonHidden = false
			self.isSecondaryButtonHidden = true
		case .none:
			self.isPrimaryButtonHidden = true
			self.isSecondaryButtonHidden = true
		}
	}

	func setEnabled(_ isEnabled: Bool, button: FooterViewModel.ButtonType) {
		switch button {
		case .primary:
			isPrimaryButtonEnabled = isEnabled
		case .secondary:
			isSecondaryButtonEnabled = isEnabled
		}
	}

	func setLoadingIndicator(_ show: Bool, disable: Bool, button: FooterViewModel.ButtonType) {
		switch button {
		case .primary:
			isPrimaryLoading = show
			isPrimaryButtonEnabled = !disable
		case .secondary:
			isSecondaryLoading = show
			isSecondaryButtonEnabled = !disable
		}
	}
}
