////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class CloseBarButtonItem: UIBarButtonItem {

	// MARK: - Init

	init(
		onTap: @escaping () -> Void
	) {
		self.onTap = onTap

		super.init()

		let closeButton = UIButton(type: .custom)
		closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.addTarget(self, action: #selector(didTap), for: .primaryActionTriggered)
		customView = closeButton

		accessibilityLabel = AppStrings.AccessibilityLabel.close
		accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	@objc
	func didTap() {
		onTap()
	}

	let onTap: () -> Void

}
