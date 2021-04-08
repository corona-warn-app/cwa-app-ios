////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

extension UITextField {
	var cgFloatValue: CGFloat {
		guard let doubleValue = NumberFormatter().number(from: self.text ?? "") else { return 0.0 }
		return CGFloat(truncating: doubleValue)
	}
}
