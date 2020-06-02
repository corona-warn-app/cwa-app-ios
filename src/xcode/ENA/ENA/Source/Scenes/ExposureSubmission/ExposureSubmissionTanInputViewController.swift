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

class ExposureSubmissionTanInputViewController: UIViewController, SpinnerInjectable, ENATanInputDelegate {
	// MARK: - Attributes.

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var infoLabel: UILabel!
	@IBOutlet var tanInput: ENATanInput!
	var initialTan: String?
	var exposureSubmissionService: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	// MARK: - View lifecycle methods.

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupView()
		fetchService()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		setButtonEnabled(enabled: true)
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

		setButtonTitle(to: AppStrings.ExposureSubmissionTanEntry.submit)
		title = AppStrings.ExposureSubmissionTanEntry.title
		setButtonEnabled(enabled: tanInput.isValid)
		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description

		descriptionLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .semibold))
		descriptionLabel.adjustsFontForContentSizeCategory = true
		descriptionLabel.lineBreakMode = .byWordWrapping
		descriptionLabel.numberOfLines = 0
		infoLabel.text = AppStrings.ExposureSubmissionTanEntry.info
		infoLabel.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .regular))
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
	func didTapBottomButton() {
		startSpinner()
		// If teleTAN is correct, show Alert Controller
		// to check permissions to request TAN.
		let teleTan = tanInput.text

		exposureSubmissionService?
			.getRegistrationToken(forKey: .teleTan(teleTan), completion: { result in
				self.stopSpinner()
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
	}

	// MARK: - ENATanInputDelegate

	func tanChanged(isValid: Bool) {
		setButtonEnabled(enabled: isValid)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Segue.labResultsSegue.rawValue,
			let vc = segue.destination as? ExposureSubmissionTestResultViewController {
			vc.exposureSubmissionService = exposureSubmissionService
			vc.testResult = .positive
		}
	}
}
