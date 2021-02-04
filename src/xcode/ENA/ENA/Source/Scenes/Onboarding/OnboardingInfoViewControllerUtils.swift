//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

enum OnboardingInfoViewControllerUtils {
	/// set up an Alert to be displayed when the user elects to skip the exposure notification permission prompt
	///
	/// - parameter skipAction: closure called when the user elects to skip the exposure notification. Onboarding should proceed.
	/// - returns: `UIAlertController` with two actions: a back action that simply dismisses the alert,
	/// 	and a skip action if the user wants to confirm their choice
	static func setupExposureConfirmationAlert(skipAction: @escaping (() -> Void)) -> UIAlertController {
		let alert = UIAlertController(
			title: AppStrings.Onboarding.onboarding_deactivate_exposure_notif_confirmation_title,
			message: AppStrings.Onboarding.onboarding_deactivate_exposure_notif_confirmation_message,
			preferredStyle: .alert
		)
		let deactivate = UIAlertAction(
			title: AppStrings.Onboarding.onboardingDoNotActivate,
			style: .default,
			handler: { _ in
				skipAction()
				alert.dismiss(animated: true, completion: nil)
			}
		)
		let back = UIAlertAction(
			title: AppStrings.Common.alertActionCancel,
			style: .cancel
		)
		alert.addAction(deactivate)
		alert.addAction(back)
		return alert
	}
}
