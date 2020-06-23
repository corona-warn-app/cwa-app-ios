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

class ExposureSubmissionHotlineViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupButtons()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	// MARK: - View setup.

	private func setUpView() {
		title = AppStrings.ExposureSubmissionHotline.title
		setupButtons()
		setupTableView()
		setupBackButton()
	}

	private func setupButtons() {
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionHotline.callButtonTitle
		navigationFooterItem?.secondaryButtonTitle = AppStrings.ExposureSubmissionHotline.tanInputButtonTitle
		navigationFooterItem?.isSecondaryButtonHidden = false
	}

	// MARK: - Data setup.

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

		dynamicTableViewModel = DynamicTableViewModel(
			[
				.section(
					header: .image(UIImage(named: "Illu_Submission_Kontakt"),
								   accessibilityLabel: AppStrings.ExposureSubmissionHotline.imageDescription,
								   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.imageDescription),
					cells: [
						.body(text: AppStrings.ExposureSubmissionHotline.description,
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.description) { _, cell, _ in
								cell.textLabel?.accessibilityTraits = .header
						}
					]
				),
				DynamicSection.section(
					cells: [
						.title2(text: AppStrings.ExposureSubmissionHotline.sectionTitle,
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.sectionTitle),
						ExposureSubmissionDynamicCell.stepCell(
							style: .body,
							title: AppStrings.ExposureSubmissionHotline.sectionDescription1,
							icon: UIImage(named: "Icons_Grey_1"),
							iconAccessibilityLabel: AppStrings.ExposureSubmissionHotline.iconAccessibilityLabel1,
							hairline: .iconAttached,
							bottomSpacing: .normal
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .headline,
							color: .enaColor(for: .textTint),
							title: AppStrings.ExposureSubmissionHotline.phoneNumber,
							hairline: .topAttached,
							bottomSpacing: .normal,
							action: .execute { [weak self] _ in self?.callHotline() }
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .footnote,
							title: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
							hairline: .topAttached,
							bottomSpacing: .large
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .body,
							title: AppStrings.ExposureSubmissionHotline.sectionDescription2,
							icon: UIImage(named: "Icons_Grey_2"),
							iconAccessibilityLabel: AppStrings.ExposureSubmissionHotline.iconAccessibilityLabel2,
							hairline: .none
						)
					])
			]
		)
	}
}

// MARK: - Segue identifiers.

extension ExposureSubmissionHotlineViewController {
	enum Segue: String, SegueIdentifiers {
		case tanInput = "tanInputSegue"
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionHotlineViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}

// MARK: - ENANavigationControllerWithFooterChild Extension.

extension ExposureSubmissionHotlineViewController {
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		callHotline()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		performSegue(withIdentifier: Segue.tanInput, sender: self)
	}

	private func callHotline() {
		if let url = URL(string: "telprompt:\(AppStrings.ExposureSubmission.hotlineNumber)") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
}
