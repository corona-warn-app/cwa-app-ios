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
import Combine

class ExposureSubmissionSymptomsOnsetViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild, RequiresDismissConfirmation {

	typealias PrimaryButtonHandler = (SymptomsOnsetOption) -> Void

	enum SymptomsOnsetOption {
		case exactDate(Date)
		case lastSevenDays
		case oneToTwoWeeksAgo
		case moreThanTwoWeeksAgo
		case preferNotToSay
	}

	// MARK: - Init

	init?(
		coder: NSCoder,
		onPrimaryButtonTap: @escaping PrimaryButtonHandler
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
		guard let selectedSymptomsOnsetSelectionOption = selectedSymptomsOnsetOption else {
			fatalError("Primary button must not be enabled before the user has selected an option")
		}

		onPrimaryButtonTap(selectedSymptomsOnsetSelectionOption)
	}

	// MARK: - Private

	private let onPrimaryButtonTap: PrimaryButtonHandler

	@Published private var selectedSymptomsOnsetOption: SymptomsOnsetOption?

	private var optionGroupSelection: OptionGroupViewModel.Selection? {
		didSet {
			switch optionGroupSelection {
			case .datePickerOption(index: 0, selectedDate: let date):
				selectedSymptomsOnsetOption = .exactDate(date)
			case .option(index: 1):
				selectedSymptomsOnsetOption = .lastSevenDays
			case .option(index: 2):
				selectedSymptomsOnsetOption = .oneToTwoWeeksAgo
			case .option(index: 3):
				selectedSymptomsOnsetOption = .moreThanTwoWeeksAgo
			case .option(index: 4):
				selectedSymptomsOnsetOption = .preferNotToSay
			case .none:
				selectedSymptomsOnsetOption = nil
			default:
				fatalError("This selection has not yet been handled.")
			}
		}
	}

	private var symptomsOnsetButtonStateSubscription: AnyCancellable?
	private var optionGroupSelectionSubscription: AnyCancellable?

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionSymptomsOnset.title
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionSymptomsOnset.continueButton

		setupTableView()

		symptomsOnsetButtonStateSubscription = $selectedSymptomsOnsetOption.receive(on: RunLoop.main).sink {
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
							text: AppStrings.ExposureSubmissionSymptomsOnset.subtitle,
							accessibilityIdentifier: nil
						),
						.body(
							text: AppStrings.ExposureSubmissionSymptomsOnset.description,
							accessibilityIdentifier: nil
						),
						.custom(
							withIdentifier: CustomCellReuseIdentifiers.optionGroupCell,
							configure: { [weak self] _, cell, _ in
								guard let self = self, let cell = cell as? DynamicTableViewOptionGroupCell else { return }

								cell.configure(
									options: [
										.datePickerOption(
											title: AppStrings.ExposureSubmissionSymptomsOnset.datePickerTitle,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSymptomsOnset.answerOptionExactDate
										),
										.option(
											title: AppStrings.ExposureSubmissionSymptomsOnset.answerOptionLastSevenDays,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSymptomsOnset.answerOptionLastSevenDays
										),
										.option(
											title: AppStrings.ExposureSubmissionSymptomsOnset.answerOptionOneToTwoWeeksAgo,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSymptomsOnset.answerOptionOneToTwoWeeksAgo
										),
										.option(
											title: AppStrings.ExposureSubmissionSymptomsOnset.answerOptionMoreThanTwoWeeksAgo,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSymptomsOnset.answerOptionMoreThanTwoWeeksAgo
										),
										.option(
											title: AppStrings.ExposureSubmissionSymptomsOnset.answerOptionPreferNotToSay,
											accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSymptomsOnset.answerOptionPreferNotToSay
										)
									],
									// The current selection needs to be provided in case the cell is recreated after leaving and reentering the screen
									initialSelection: self.optionGroupSelection
								)

								self.optionGroupSelectionSubscription = cell.$selection.sink {
									self.optionGroupSelection = $0
								}
							}
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
