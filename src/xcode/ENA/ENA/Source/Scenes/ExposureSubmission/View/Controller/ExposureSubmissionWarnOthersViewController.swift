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

class ExposureSubmissionWarnOthersViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Attributes.

	private(set) weak var exposureSubmissionService: ExposureSubmissionService?
	private(set) weak var coordinator: ExposureSubmissionCoordinating?

	// MARK: - Initializers.

	init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating, exposureSubmissionService: ExposureSubmissionService) {
		self.coordinator = coordinator
		self.exposureSubmissionService = exposureSubmissionService
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}

	// MARK: Setup helpers.

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionWarnOthers.title
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionWarnOthers.continueButton
		setupTableView()
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		dynamicTableViewModel = dynamicTableViewModel()
	}

	// MARK: - ExposureSubmissionService Helpers.

	internal func startSubmitProcess() {
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
		 })
	}
}

// MARK: ENANavigationControllerWithFooterChild methods.

extension ExposureSubmissionWarnOthersViewController {
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		startSubmitProcess()
	}
}

// MARK: - DynamicTableViewModel convenience setup methods.

private extension ExposureSubmissionWarnOthersViewController {
	private func dynamicTableViewModel() -> DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_AndereWarnen"),
						accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250),
					cells: [
						.title2(text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle),
						.body(text: AppStrings.ExposureSubmissionWarnOthers.description,
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description),
						.custom(withIdentifier: CustomCellReuseIdentifiers.roundedCell,
								configure: { _, cell, _ in
									guard let appUsagesOver16Cell = cell as? DynamicTableViewRoundedCell else { return }
									appUsagesOver16Cell.configure(title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesText
									),
									textStyle: .textContrast,
									backgroundStyle: .riskNeutral
									)

						}),
						.custom(withIdentifier: CustomCellReuseIdentifiers.roundedCell,
								configure: { _, cell, _ in
									guard let privacyStatementCell = cell as? DynamicTableViewRoundedCell else { return }
									privacyStatementCell.configure(
										title: NSMutableAttributedString(
											string: AppStrings.ExposureSubmissionWarnOthers.dataPrivacyTitle
										),
										body: NSMutableAttributedString(
											string: AppStrings.ExposureSubmissionWarnOthers.dataPrivacyDescription
										),
										textStyle: .textPrimary1,
										backgroundStyle: .separator
									)
						})
					]
				)
			)
		}
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionWarnOthersViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
