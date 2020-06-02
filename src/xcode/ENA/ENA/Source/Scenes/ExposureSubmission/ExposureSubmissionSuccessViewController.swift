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

final class ExposureSubmissionSuccessViewController: DynamicTableViewController {
	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTitle()
		setUpView()
		setButtonTitle(to: AppStrings.ExposureSubmissionSuccess.button)
	}

	private func setUpView() {
		navigationItem.hidesBackButton = true
		tableView.register(DynamicTableViewStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		dynamicTableViewModel = .data
	}

	private func setupTitle() {
		title = AppStrings.ExposureSubmissionSuccess.title
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	func didTapBottomButton() {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func unwindToExposureSubmissionIntro(_: UIStoryboardSegue) {}
}

extension ExposureSubmissionSuccessViewController: ExposureSubmissionNavigationControllerChild {}

private extension DynamicTableViewModel {
	static let data = DynamicTableViewModel([
		DynamicSection.section(
			header: .image(UIImage(named: "Illu_Submission_VielenDank")),
			separators: false,
			cells: [
				.regular(text: AppStrings.ExposureSubmissionSuccess.description),
				.bigBold(text: AppStrings.ExposureSubmissionSuccess.listTitle),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem1,
							image: UIImage(named: "Icons - Hotline"),
							hasSeparators: false,
							isCircle: true,
							iconTintColor: .preferredColor(for: .negativeRisk)
						)
					}
				),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem2,
							image: UIImage(named: "Icons - Home"),
							isCircle: true,
							iconTintColor: .preferredColor(for: .negativeRisk)
						)
					}
				),
				.bigBold(text: AppStrings.ExposureSubmissionSuccess.subTitle),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem2_1,
							image: UIImage(named: "Icons_Dark_Dot"),
							hasSeparators: false,
							isCircle: true,
							iconTintColor: .preferredColor(for: .textPrimary1)
						)
				}
				),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem2_2,
							image: UIImage(named: "Icons_Dark_Dot"),
							hasSeparators: false,
							isCircle: true,
							iconTintColor: .preferredColor(for: .textPrimary1)
						)
				}
				),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem2_3,
							image: UIImage(named: "Icons_Dark_Dot"),
							hasSeparators: false,
							isCircle: true,
							iconTintColor: .preferredColor(for: .textPrimary1)
						)
				}
				),
				.identifier(
					ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell,
					action: .none,
					configure: { _, cell, _ in
						guard let cell = cell as? DynamicTableViewStepCell else { return }
						cell.configure(
							text: AppStrings.ExposureSubmissionSuccess.listItem2_4,
							image: UIImage(named: "Icons_Dark_Dot"),
							hasSeparators: false,
							isCircle: true,
							iconTintColor: .preferredColor(for: .textPrimary1)
						)
				}
				)
			]
		)
	])
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionSuccessViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
