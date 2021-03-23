////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class FooterViewModel {

	// MARK: - Init
	
	init(
		primaryButtonName: String? = nil,
		secondaryButtonName: String? = nil,
		primaryIdentifier: String = AccessibilityIdentifiers.General.primaryFooterButton,
		secondaryIdentifier: String = AccessibilityIdentifiers.General.secondaryFooterButton,
		isPrimaryButtonEnabled: Bool = true,
		isSecondaryButtonEnabled: Bool = true,
		isPrimaryButtonHidden: Bool = false,
		isSecondaryButtonHidden: Bool = false,
		primaryButtonColor: UIColor? = nil,
		secondaryButtonColor: UIColor? = nil,
		backgroundColor: UIColor = .enaColor(for: .background)
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
		self.backgroundColor = backgroundColor
		updateHeight()
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
	let primaryIdentifier: String
	let secondaryIdentifier: String

	private(set) var isPrimaryButtonHidden: Bool
	private(set) var isSecondaryButtonHidden: Bool

	@OpenCombine.Published private(set) var height: CGFloat = 0.0
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
		updateHeight()
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

	// MARK: - Private

	private func updateHeight() {
		let height: CGFloat
		switch (isPrimaryButtonHidden, isSecondaryButtonHidden) {
		case(false, false):
			height = buttonHeight * 2 + spacer + topBottomInset * 2
		case(true, false), (false, true):
			height = buttonHeight + spacer + topBottomInset * 2
		case(true, true):
			height = 0.0
		}
		self.height = height
	}

}
