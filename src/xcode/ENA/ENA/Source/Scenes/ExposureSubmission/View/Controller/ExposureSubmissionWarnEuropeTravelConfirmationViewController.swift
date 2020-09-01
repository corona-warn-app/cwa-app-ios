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

class ExposureSubmissionWarnEuropeTravelConfirmationViewController: DynamicTableViewController, ExposureSubmittableViewController {

	enum TravelConfirmationOption {
		case yes, no, preferNotToSay
	}

	// MARK: - Init

	init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating, exposureSubmissionService: ExposureSubmissionService) {
		self.coordinator = coordinator
		self.exposureSubmissionService = exposureSubmissionService

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
		if selectedTravelConfirmationOption == .yes {
			coordinator?.showWarnEuropeCountrySelectionScreen()
		} else {
			startSubmitProcess()
		}
	}

	// MARK: - Internal

	private(set) weak var exposureSubmissionService: ExposureSubmissionService?
	private(set) weak var coordinator: ExposureSubmissionCoordinating?

	// MARK: - Private

	@Published private var selectedTravelConfirmationOption: TravelConfirmationOption?

	private var optionGroupSelection: OptionGroupViewModel.Selection? {
		didSet {
			guard case let .option(index: index) = optionGroupSelection else { return }

			switch index {
			case 0:
				selectedTravelConfirmationOption = .yes
			case 1:
				selectedTravelConfirmationOption = .no
			case 2:
				selectedTravelConfirmationOption = .preferNotToSay
			default:
				break
			}
		}
	}

	private var travelOptionConfirmationButtonStateSubscription: AnyCancellable?
	private var optionGroupSelectionSubscription: AnyCancellable?

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.title
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.continueButton

		setupTableView()

		travelOptionConfirmationButtonStateSubscription = $selectedTravelConfirmationOption.receive(on: RunLoop.main).sink {
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
							text: AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description1,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnEuropeTravelConfirmation.description1
						),
						.custom(
							withIdentifier: CustomCellReuseIdentifiers.optionGroupCell,
							configure: { [weak self] _, cell, _ in
								guard let cell = cell as? DynamicTableViewOptionGroupCell else { return }

								cell.configure(
									options: [
										.option(title: AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionYes),
										.option(title: AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionNo),
										.option(title: AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.answerOptionNone)
									],
									// The current selection needs to be provided in case the cell is recreated after leaving and reentering the screen
									initialSelection: self?.optionGroupSelection
								)

								self?.optionGroupSelectionSubscription = cell.$selection.sink {
									self?.optionGroupSelection = $0
								}
							}
						),
						.body(
							text: AppStrings.ExposureSubmissionWarnEuropeTravelConfirmation.description2,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnEuropeTravelConfirmation.description2
						)
					]
				)
			)
		}
	}

}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionWarnEuropeTravelConfirmationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case optionGroupCell
	}
}
