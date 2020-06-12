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

class ExposureSubmissionTanInputViewController: UIViewController, SpinnerInjectable {
	// MARK: - Attributes.

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var contentView: UIView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var errorLabel: UILabel!
	@IBOutlet var errorView: UIView!
	@IBOutlet var tanInput: ENATanInput!

	var initialTan: String?
	var exposureSubmissionService: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	// MARK: - View lifecycle methods.

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupView()
		setupBackButton()
		fetchService()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		setButtonEnabled(enabled: true)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Segue.labResultsSegue.rawValue,
			let vc = segue.destination as? ExposureSubmissionTestResultViewController {
			vc.exposureSubmissionService = exposureSubmissionService
			vc.testResult = .positive
		}
	}

	// MARK: - Helper methods.

	private func setupView() {
		tanInput.delegate = self
		if let tan = initialTan {
			tanInput.clear()
			tanInput.insertText(tan)
			initialTan = nil
		} else {
			tanInput.becomeFirstResponder()
		}
		hideSecondaryButton()
		setButtonTitle(to: AppStrings.ExposureSubmissionTanEntry.submit)
		title = AppStrings.ExposureSubmissionTanEntry.title
		setButtonEnabled(enabled: tanInput.isValid)
		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
		errorView.alpha = 0
	}

	private func fetchService() {
		exposureSubmissionService = exposureSubmissionService ??
			(navigationController as? ExposureSubmissionNavigationController)?
			.getExposureSubmissionService()
	}
}

extension ExposureSubmissionTanInputViewController {
	enum Segue: String, SegueIdentifiers {
		case sentSegue
		case labResultsSegue
	}
}

// MARK: - ExposureSubmissionNavigationControllerChild methods.

extension ExposureSubmissionTanInputViewController: ExposureSubmissionNavigationControllerChild {
	func didTapButton() {
		submitTan()
	}

	@discardableResult
	func submitTan() -> Bool {
		guard tanInput.isValid && tanInput.isChecksumValid else { return false }

		startSpinner()
		setButtonEnabled(enabled: false)
		// If teleTAN is correct, show Alert Controller
		// to check permissions to request TAN.
		let teleTan = tanInput.text

		exposureSubmissionService?
			.getRegistrationToken(forKey: .teleTan(teleTan), completion: { result in
				self.stopSpinner()
				self.setButtonEnabled(enabled: true)
				switch result {
				case let .failure(error):
					let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
					self.present(alert, animated: true, completion: nil)
					return
				case .success:
					self.performSegue(
						withIdentifier: Segue.labResultsSegue,
						sender: self
					)
				}
        })

		return true
	}
}

	// MARK: - ENATanInputDelegate
extension ExposureSubmissionTanInputViewController: ENATanInputDelegate {
	func enaTanInputDidBeginEditing(_ tanInput: ENATanInput) {
		let rect = contentView.convert(tanInput.frame, from: tanInput)
		scrollView.scrollRectToVisible(rect, animated: true)
	}

	func enaTanInput(_ tanInput: ENATanInput, didChange text: String, isValid: Bool, isChecksumValid: Bool, isBlocked: Bool) {
		setButtonEnabled(enabled: (isValid && isChecksumValid))
		UIView.animate(withDuration: CATransaction.animationDuration()) {
			if isValid && !isChecksumValid {
				self.errorLabel.text = AppStrings.ExposureSubmissionTanEntry.invalidError
				self.errorView.alpha = 1
			} else if isBlocked {
				self.errorLabel.text = AppStrings.ExposureSubmissionTanEntry.invalidCharacterError
				self.errorView.alpha = 1
			} else {
				self.errorView.alpha = 0
			}

			self.view.layoutIfNeeded()
		}
	}

	func enaTanInputDidTapReturn(_ tanInput: ENATanInput) -> Bool {
		return submitTan()
	}
}
