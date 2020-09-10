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
	
	// MARK: - Init

	init?(
		coder: NSCoder,
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void
	) {
		self.onPrimaryButtonTap = onPrimaryButtonTap

		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrimaryButtonTap { [weak self] isLoading in
		   self?.navigationFooterItem?.isPrimaryButtonLoading = isLoading
		   self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
		}
	}

	// MARK: - Private

	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void

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

	private func dynamicTableViewModel() -> DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_AndereWarnen"),
						accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250
					),
					cells: [
						.title2(text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle),
						.body(text: AppStrings.ExposureSubmissionWarnOthers.description,
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description),
						.custom(
							withIdentifier: CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let appUsagesOver16Cell = cell as? DynamicTableViewRoundedCell else { return }

								appUsagesOver16Cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesTitle
									),
									body: NSMutableAttributedString(
										string: AppStrings.ExposureSubmissionWarnOthers.consentUnderagesText
									),
									textStyle: .textContrast,
									backgroundStyle: .riskNeutral
								)
							}
						),
						.custom(
							withIdentifier: CustomCellReuseIdentifiers.roundedCell,
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
							}
						)
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
