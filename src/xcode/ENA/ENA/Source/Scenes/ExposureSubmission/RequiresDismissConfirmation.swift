//
// Corona-Warn-App
//
// SAP SE and all other contributors
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

import UIKit

/// The `RequiresDismissConfirmation`  protocol can be implemented by view controllers that are
/// managed by the `ExposureSubmissionCoordinator` to react to dismissals (either by pressing the close button
/// or the swipe down gesture). The protocol comes with a default implementation that displays a generic confirmation popup.
protocol RequiresDismissConfirmation: UIViewController {
	/// willDismiss(_:) is called by the `ExposureSubmissionCoordinator` when the view controller is about to be removed
	/// from the navigation controller view stack.
	/// - Parameters:
	///   - shouldDismiss: callback that takes true if the dismissal of the current view controller should proceed.
	func attemptDismiss(_ shouldDismiss: @escaping ((Bool) -> Void))
}

extension RequiresDismissConfirmation {

	func attemptDismiss(_ shouldDismiss: @escaping ((Bool) -> Void)) {
		let alert = setupErrorAlert(
			title: AppStrings.ExposureSubmission.confirmDismissPopUpTitle,
			message: AppStrings.ExposureSubmission.confirmDismissPopUpText,
			okTitle: AppStrings.Common.alertActionNo,
			secondaryActionTitle: AppStrings.Common.alertActionYes,
			completion: { shouldDismiss(false) },
			secondaryActionCompletion: { shouldDismiss(true) }
		)

		present(alert, animated: true)
	}
}
