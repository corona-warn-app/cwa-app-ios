////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AddTraceLocationCellModel {

	// MARK: - Internal

	let text: String = AppStrings.TraceLocations.Overview.addButtonTitle

	@OpenCombine.Published var iconImage: UIImage? = UIImage(named: "Icon_Add")
	@OpenCombine.Published var textColor: UIColor = .enaColor(for: .textPrimary1)
	@OpenCombine.Published var accessibilityTraits: UIAccessibilityTraits = [.button]

	func setEnabled(_ enabled: Bool) {
		iconImage = enabled ? UIImage(named: "Icon_Add") : UIImage(named: "Icon_Add_Grey")
		textColor = enabled ? .enaColor(for: .textPrimary1) : .enaColor(for: .textPrimary2)
		accessibilityTraits = enabled ? [.button] : [.button, .notEnabled]
	}
    
}
