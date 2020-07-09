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

import UIKit

class ExposureSubmissionIntroViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Attributes.
	
	private var exposureSubmissionService: ExposureSubmissionService?

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmission.continueText

		setupView()
		setupBackButton()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.continueText
	}

	// MARK: - Setup helpers.

	private func setupView() {
		setupTitle()
		setupTableView()
	}

	private func setupTitle() {
		navigationItem.largeTitleDisplayMode = .always
		title = AppStrings.ExposureSubmissionIntroduction.title
	}

	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		dynamicTableViewModel = .intro
	}

	// MARK: - ENANavigationControllerWithFooterChild methods.

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		let service = (navigationController as? ExposureSubmissionNavigationController)?.exposureSubmissionService
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionOverviewViewController.self) { coder in
			ExposureSubmissionOverviewViewController(coder: coder, service: service)
		}
		navigationController.pushViewController(vc, animated: true)
	}
}

private extension DynamicTableViewModel {
	static let intro = DynamicTableViewModel([
		.navigationSubtitle(text: AppStrings.ExposureSubmissionIntroduction.subTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.subTitle),
		.section(
			header: .image(
				UIImage(named: "Illu_Submission_Funktion1"),
				accessibilityLabel: AppStrings.ExposureSubmissionIntroduction.accImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.General.image,
				height: 200
			),
			separators: false,
			cells: [
				.headline(text: AppStrings.ExposureSubmissionIntroduction.usage01,
						  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.usage01),
				.body(text: AppStrings.ExposureSubmissionIntroduction.usage02,
					  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.usage02),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem1),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem2),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem3),
				ExposureSubmissionDynamicCell.stepCell(bulletPoint: AppStrings.ExposureSubmissionIntroduction.listItem4)
			]
		)
	])
}

private extension ExposureSubmissionIntroViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
