////
// 🦠 Corona-Warn-App
//

import UIKit

class AccessibleStackView: UIStackView {
	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureAxis()
	}
	required init(coder: NSCoder) {
		super.init(coder: coder)
		configureAxis()
	}
	// MARK: - Overrides
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		configureAxis()
	}
	// MARK: - Private
	private func configureAxis() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			axis = .vertical
		} else {
			axis = .horizontal
		}
	}
}
