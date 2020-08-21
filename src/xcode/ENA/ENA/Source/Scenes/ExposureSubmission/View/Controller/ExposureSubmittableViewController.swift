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

protocol ExposureSubmittableViewController: ENANavigationControllerWithFooterChild {

	var exposureSubmissionService: ExposureSubmissionService? { get }
	var coordinator: ExposureSubmissionCoordinating? { get }

	func startSubmitProcess()

}

extension ExposureSubmittableViewController {

	// MARK: - ExposureSubmissionService Helpers.

	func startSubmitProcess() {
		navigationFooterItem?.isPrimaryButtonLoading = true
		navigationFooterItem?.isPrimaryButtonEnabled = false

		exposureSubmissionService?.submitExposure { error in
			switch error {
			// We continue the regular flow even if there are no keys collected.
			case .none, .noKeys:
				self.coordinator?.showThankYouScreen()

			// Custom error handling for EN framework related errors.
			case .internal, .unsupported, .rateLimited:
				guard let error = error else {
					logError(message: "error while parsing EN error.")
					return
				}
				self.showENErrorAlert(error)

			case .some(let error):
				logError(message: "error: \(error.localizedDescription)", level: .error)
				let alert = self.setupErrorAlert(message: error.localizedDescription)
				self.present(alert, animated: true, completion: {
					self.navigationFooterItem?.isPrimaryButtonLoading = false
					self.navigationFooterItem?.isPrimaryButtonEnabled = true
				})
			}
		}
	}

	// MARK: - UI-related helpers.

	/// Instantiates and shows an alert with a "More Info" button for
	/// the EN errors. Assumes that the passed in `error` is either of type
	/// `.internal`, `.unsupported` or `.rateLimited`.
	func showENErrorAlert(_ error: ExposureSubmissionError) {
		logError(message: "error: \(error.localizedDescription)", level: .error)
		let alert = createENAlert(error)

		self.present(alert, animated: true, completion: {
			self.navigationFooterItem?.isPrimaryButtonLoading = false
			self.navigationFooterItem?.isPrimaryButtonEnabled = true
		})
	}

	/// Creates an error alert for the EN errors.
	func createENAlert(_ error: ExposureSubmissionError) -> UIAlertController {
		return self.setupErrorAlert(
			message: error.localizedDescription,
			secondaryActionTitle: AppStrings.Common.errorAlertActionMoreInfo,
			secondaryActionCompletion: {
				guard let url = error.faqURL else {
					logError(message: "Unable to open FAQ page.", level: .error)
					return
				}

				UIApplication.shared.open(
					url,
					options: [:]
				)
			}
		)
	}

}
