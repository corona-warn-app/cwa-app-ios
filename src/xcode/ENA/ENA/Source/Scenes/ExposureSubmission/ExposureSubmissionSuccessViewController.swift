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
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		dynamicTableViewModel = .data
	}

	private func setupTitle() {
		title = AppStrings.ExposureSubmissionSuccess.title
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
	}
}

extension ExposureSubmissionSuccessViewController: ExposureSubmissionNavigationControllerChild {
	func didTapButton() {
		dismiss(animated: true, completion: nil)
	}
}

private extension DynamicTableViewModel {
	static let data = DynamicTableViewModel([
		DynamicSection.section(
			header: .image(
				UIImage(named: "Illu_Submission_VielenDank"),
				accessibilityLabel: AppStrings.ExposureSubmissionSuccess.accImageDescription,
				accessibilityIdentifier: "AppStrings.ExposureSubmissionSuccess.accImageDescription"
			),
			separators: false,
			cells: [
				.body(text: AppStrings.ExposureSubmissionSuccess.description,
					  accessibilityIdentifier: "AppStrings.ExposureSubmissionSuccess.description"),
				.title2(text: AppStrings.ExposureSubmissionSuccess.listTitle,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionSuccess.listTitle"),

				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItem1,
					icon: UIImage(named: "Icons - Hotline")?.withTintColor(.enaColor(for: .riskHigh)),
					hairline: .none,
					bottomSpacing: .normal
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItem2,
					icon: UIImage(named: "Icons - Home")?.withTintColor(.enaColor(for: .riskHigh)),
					hairline: .none,
					bottomSpacing: .large
				),

				.title2(text: AppStrings.ExposureSubmissionSuccess.subTitle,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionSuccess.subTitle"),

				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionSuccess.listItem2_1),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionSuccess.listItem2_2),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionSuccess.listItem2_3),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionSuccess.listItem2_4)
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
