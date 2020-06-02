//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
		let goBack = UIAlertAction(
			title: AppStrings.Onboarding.onboardingBack,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true, completion: nil)
			}
		)
		let deactivate = UIAlertAction(
			title: AppStrings.Onboarding.onboardingDoNotActivate,
			style: .default,
			handler: { _ in
				skipAction()
				alert.dismiss(animated: true, completion: nil)
			}
		)
		alert.addAction(goBack)
		alert.addAction(deactivate)
		alert.preferredAction = goBack
		return alert
	}
}
