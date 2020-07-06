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

import Foundation
import UIKit
extension UIViewController {
	func alertError(message: String?, title: String?, completion: (() -> Void)? = nil) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: AppStrings.Common.alertActionOk, style: .default, handler: { _ in completion?() })
		alertController.addAction(okAction)
		present(alertController, animated: true, completion: nil)
	}

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
	func setupErrorAlert(
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
