////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class CloseBarButtonItem: UIBarButtonItem {

	// MARK: - Init

	init(
		mode: Mode = .normal,
		onTap: @escaping () -> Void,
		accessibilityIdentifierSuffix: String = ""
	) {
		self.onTap = onTap
		super.init()
		accessibilityLabel = AppStrings.AccessibilityLabel.close
		accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close + accessibilityIdentifierSuffix
		setup(mode)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	enum Mode {
		case normal
		case contrast
	}

	@objc
	func didTap() {
		onTap()
	}

	// MARK: - Private

	private let onTap: () -> Void

	private func setup(_ mode: Mode) {
		let closeButton = UIButton(type: .custom)
		switch mode {

		case .normal:
			closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)

		case .contrast:
			closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap - Contrast"), for: .highlighted)
		}
		closeButton.addTarget(self, action: #selector(didTap), for: .primaryActionTriggered)
		customView = closeButton
	}

}
