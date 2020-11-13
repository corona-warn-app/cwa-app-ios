//
// 🦠 Corona-Warn-App
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
