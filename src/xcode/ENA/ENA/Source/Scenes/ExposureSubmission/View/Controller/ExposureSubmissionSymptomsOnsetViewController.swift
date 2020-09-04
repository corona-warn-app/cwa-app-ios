//
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
//

import UIKit
import Combine

class ExposureSubmissionSymptomsOnsetViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	enum SymptomsOnsetSelectionOption {
		case date(Date)
	}

	// MARK: - Init

	init?(
		coder: NSCoder,
		onPrimaryButtonTap: @escaping (SymptomsOnsetSelectionOption, @escaping (Bool) -> Void) -> Void
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
		guard let selectedSymptomsOnsetSelectionOption = selectedSymptomsOnsetSelectionOption else {
			fatalError("Primary button must not be enabled before the user has selected an option")
		}

		onPrimaryButtonTap(selectedSymptomsOnsetSelectionOption) { [weak self] isLoading in
		   self?.navigationFooterItem?.isPrimaryButtonLoading = isLoading
		   self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
		}
	}

	// MARK: - Private

	private let onPrimaryButtonTap: (SymptomsOnsetSelectionOption, @escaping (Bool) -> Void) -> Void

	@Published private var selectedSymptomsOnsetSelectionOption: SymptomsOnsetSelectionOption?

	private var optionGroupSelection: OptionGroupViewModel.Selection? {
		didSet {
			// Sync selection
		}
	}

	private var symptomsOnsetButtonStateSubscription: AnyCancellable?
	private var optionGroupSelectionSubscription: AnyCancellable?

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionWarnEuropeCountrySelection.title
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionWarnEuropeCountrySelection.continueButton

		setupTableView()

		symptomsOnsetButtonStateSubscription = $selectedSymptomsOnsetSelectionOption.receive(on: RunLoop.main).sink {
			self.navigationFooterItem?.isPrimaryButtonEnabled = $0 != nil
		}
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self

		tableView.register(
			DynamicTableViewOptionGroupCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.optionGroupCell.rawValue
		)

		dynamicTableViewModel = dynamicTableViewModel()
	}

	private func dynamicTableViewModel() -> DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .none,
					cells: [
						.headline(
							text: AppStrings.ExposureSubmissionWarnEuropeCountrySelection.description1,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnEuropeCountrySelection.description1
						),
						.custom(
							withIdentifier: CustomCellReuseIdentifiers.optionGroupCell,
							configure: { [weak self] _, cell, _ in
								guard let self = self, let cell = cell as? DynamicTableViewOptionGroupCell else { return }

								cell.configure(
									options: [
										.datePickerOption(title: "!!! Genaues Datum"),
										.option(
											title: AppStrings.ExposureSubmissionWarnEuropeCountrySelection.answerOptionNone,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnEuropeCountrySelection.answerOptionNone
										)
									],
									// The current selection needs to be provided in case the cell is recreated after leaving and reentering the screen
									initialSelection: self.optionGroupSelection
								)

								self.optionGroupSelectionSubscription = cell.$selection.sink {
									self.optionGroupSelection = $0
								}
							}
						),
						.body(
							text: AppStrings.ExposureSubmissionWarnEuropeCountrySelection.description2,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnEuropeCountrySelection.description2
						)
					]
				)
			)
		}
	}

}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionSymptomsOnsetViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case optionGroupCell
	}
}
