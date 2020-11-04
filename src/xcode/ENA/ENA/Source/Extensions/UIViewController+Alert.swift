import Foundation
import UIKit
extension UIViewController {
	func alertError(message: String?, title: String?, optInActions: [UIAlertAction]? = nil, completion: (() -> Void)? = nil) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: AppStrings.Common.alertActionOk, style: .default, handler: { _ in completion?() })
		alertController.addAction(okAction)
		if let optionalActions = optInActions {
			optionalActions.forEach({ action in alertController.addAction(action) })
		}
		present(alertController, animated: true, completion: completion)
	}

	func setupErrorAlert(
		title: String? = nil,
		message: String,
		okTitle: String? = nil,
		secondaryActionTitle: String? = nil,
		completion: (() -> Void)? = nil,
		secondaryActionCompletion: (() -> Void)? = nil
	) -> UIAlertController {
		return UIAlertController.errorAlert(
			title: title,
			message: message,
			okTitle: okTitle,
			secondaryActionTitle: secondaryActionTitle,
			completion: completion,
			secondaryActionCompletion: secondaryActionCompletion
		)
	}

	/// This method checks whether the below conditions in regards to background fetching have been met
	/// and creates the corresponding alert. Note that `store` is needed in the alert closure in order
	/// to track that the alert has already been shown once.
	/// The error alert should only be shown:
	/// - once
	/// - if the background refresh is disabled
	/// - if the user is __not__ in power saving mode, because in this case the background
	///   refresh is disabled automatically. Therefore we have to explicitly check this.
	func createBackgroundFetchAlert(
		status: UIBackgroundRefreshStatus,
		inLowPowerMode: Bool,
		hasSeenAlertBefore: Bool,
		store: Store) -> UIAlertController? {

		if status == .available || inLowPowerMode || hasSeenAlertBefore { return nil }

		let openSettings: (() -> Void) = {
			if let url = URL(string: UIApplication.openSettingsURLString) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}

		return setupErrorAlert(
			title: AppStrings.Common.backgroundFetch_AlertTitle,
			message: AppStrings.Common.backgroundFetch_AlertMessage,
			okTitle: AppStrings.Common.backgroundFetch_OKTitle,
			secondaryActionTitle: AppStrings.Common.backgroundFetch_SettingsTitle,
			completion: { store.hasSeenBackgroundFetchAlert = true },
			secondaryActionCompletion: openSettings
		)
	}

}

extension UIAlertController {

	/// This method helps to build a alert for displaying error messages.
	/// - Parameters:
	///   - title: The title of the alert. If omitted, it will use the general error title.
	///   - message: The description of the alert.
	///   - okTitle: The text of the ok action.
	///   - secondaryActionTitle: The text of the secondary action, if there is one.
	///   - hasSecondaryAction: Indicates whether an alert has a secondary action or not.
	///   - completion: The completion handler for the "ok" action.
	///   - secondaryActionCompletion: The completion handler for the secondary action.
	/// - Returns: An alert with either one or two actions, with the specified completion handlers
	/// and texts.
	static func errorAlert(
		title: String? = nil,
		message: String,
		okTitle: String? = nil,
		secondaryActionTitle: String? = nil,
		completion: (() -> Void)? = nil,
		secondaryActionCompletion: (() -> Void)? = nil
	) -> UIAlertController {
		let alert = UIAlertController(
			title: title ?? AppStrings.ExposureSubmission.generalErrorTitle,
			message: message,
			preferredStyle: .alert
		)
		let ok = UIAlertAction(
			title: okTitle ?? AppStrings.Common.alertActionOk,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true, completion: completion)
			}
		)

		alert.addAction(ok)
		if secondaryActionTitle != nil {
			let retryAction = UIAlertAction(
				title: secondaryActionTitle,
				style: .default,
				handler: { _ in
					alert.dismiss(animated: true, completion: secondaryActionCompletion)

				}
			)
			alert.addAction(retryAction)
		}
		return alert
	}

}
