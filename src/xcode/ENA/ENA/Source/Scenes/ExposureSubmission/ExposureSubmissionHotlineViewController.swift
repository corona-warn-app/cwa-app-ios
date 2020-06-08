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

class ExposureSubmissionHotlineViewController: DynamicTableViewController {
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
		hideSecondaryButton()
	}

	// MARK: - View setup.

	private func setUpView() {
		title = AppStrings.ExposureSubmissionHotline.title
		setupButtons()
		setupTableView()
		setupBackButton()
	}

	private func setupButtons() {
		setButtonTitle(to: AppStrings.ExposureSubmissionHotline.callButtonTitle)
		setSecondaryButtonTitle(to: AppStrings.ExposureSubmissionHotline.tanInputButtonTitle)
		showSecondaryButton()
	}

	// MARK: - Data setup.

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(DynamicTableViewStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

		dynamicTableViewModel = DynamicTableViewModel(
			[
				.section(
					header: .image(UIImage(named: "Illu_Submission_Kontakt"), accessibilityLabel: nil),
					cells: [
						.body(text: AppStrings.ExposureSubmissionHotline.description)
					]
				),
				DynamicSection.section(
					cells: [
						.title2(text: AppStrings.ExposureSubmissionHotline.sectionTitle),
						.identifier(CustomCellReuseIdentifiers.stepCell,
									action: .execute { _ in self.callHotline() },
									configure: { _, cell, _ in
										guard let cell = cell as? DynamicTableViewStepCell else { return }
										cell.configure(
											text: AppStrings.ExposureSubmissionHotline.sectionDescription1,
											attributedText: self.getAttributedStrings(),
											image: UIImage(named: "Icons_Grey_1")
										)
                        }),
						.identifier(CustomCellReuseIdentifiers.stepCell, action: .none, configure: { _, cell, _ in
							guard let cell = cell as? DynamicTableViewStepCell else { return }
							cell.configure(
								text: AppStrings.ExposureSubmissionHotline.sectionDescription2,
								image: UIImage(named: "Icons_Grey_2")
							)
                            })
					])
			]
		)
	}

	/// Gets the attributed string that makes the phone number blue and bold.
	private func getAttributedStrings() -> [NSAttributedString] {
		let font: UIFont = .preferredFont(forTextStyle: .body)
		let boldFont: UIFont = UIFont.boldSystemFont(ofSize: font.pointSize)
		let color: UIColor = .enaColor(for: .textTint)
		let attr1: [NSAttributedString.Key: Any] = [.font: boldFont, .foregroundColor: color]
		let word = NSAttributedString(
			string: AppStrings.ExposureSubmissionHotline.phoneNumber,
			attributes: attr1
		)

		let attr2: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .footnote)]
		let description = NSAttributedString(
			string: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
			attributes: attr2
		)

		return [word, description]
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

// MARK: - ExposureSubmissionNavigationControllerChild Extension.

extension ExposureSubmissionHotlineViewController: ExposureSubmissionNavigationControllerChild {
	func didTapButton() {
		callHotline()
	}

	func didTapSecondButton() {
		performSegue(withIdentifier: Segue.tanInput, sender: self)
	}

	private func callHotline() {
		if let url = URL(string: "telprompt:\(AppStrings.ExposureDetection.hotlineNumber)") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
}
