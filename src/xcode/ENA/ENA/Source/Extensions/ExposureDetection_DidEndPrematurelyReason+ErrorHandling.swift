//
// 🦠 Corona-Warn-App
//

import UIKit
import ExposureNotification

extension ExposureDetection.DidEndPrematurelyReason {
	func errorAlertController(rootController: UIViewController) -> UIAlertController? {
		switch self {
		case let .noSummary(error):
			return makeAlertControllerForENError(error, rootController: rootController)
		case .noDiskSpace:
			return rootController.setupErrorAlert(message: localizedDescription)
		case .wrongDeviceTime:
			return rootController.setupErrorAlert(message: localizedDescription)
		default:
			// Don't show an alert for all other errors.
			return nil
		}
	}

	private func makeAlertControllerForENError(_ error: Error?, rootController: UIViewController) -> UIAlertController {
		switch error {
		case let error as ENError:
			let openFAQ: (() -> Void)? = {
				guard let url = error.faqURL else { return nil }
				return {
					UIApplication.shared.open(url, options: [:])
				}
			}()
			return rootController.setupErrorAlert(
				message: localizedDescription,
				secondaryActionTitle: AppStrings.Common.errorAlertActionMoreInfo,
				secondaryActionCompletion: openFAQ
			)
		default:
			return rootController.setupErrorAlert(
				message: localizedDescription
			)
		}
	}
}
