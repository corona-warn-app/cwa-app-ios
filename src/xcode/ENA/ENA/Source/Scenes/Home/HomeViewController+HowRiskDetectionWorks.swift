//
// 🦠 Corona-Warn-App
//

import UIKit

extension UIAlertController {
	class func localizedHowRiskDetectionWorksAlertController(
		maximumNumberOfDays: Int
	) -> UIAlertController {
		let title = NSLocalizedString("How_Risk_Detection_Works_Alert_Title", comment: "")
		let message = String(
			format: NSLocalizedString(
				"How_Risk_Detection_Works_Alert_Message",
				comment: ""
			),
			maximumNumberOfDays
		)

		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: NSLocalizedString("Alert_ActionOk", comment: ""),
				style: .default
			)
		)

		return alert
	}
}
