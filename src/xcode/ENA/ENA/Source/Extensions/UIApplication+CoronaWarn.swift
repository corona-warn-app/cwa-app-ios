//
// 🦠 Corona-Warn-App
//

import UIKit
extension UIApplication {
	class func coronaWarnDelegate() -> CoronaWarnAppDelegate {
		// swiftlint:disable:next force_cast
		shared.delegate as! CoronaWarnAppDelegate
	}
}
