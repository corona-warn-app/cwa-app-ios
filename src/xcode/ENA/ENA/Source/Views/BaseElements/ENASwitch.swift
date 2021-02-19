//
// 🦠 Corona-Warn-App
//

import UIKit

/// A Switch UI control which has the same behavior of UISwitch, but with different tint color.
@IBDesignable
final class ENASwitch: UISwitch {
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customizeSwitch()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		customizeSwitch()
	}

	private func customizeSwitch() {
		onTintColor = .enaColor(for: .buttonPrimary)
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		customizeSwitch()
	}
}
