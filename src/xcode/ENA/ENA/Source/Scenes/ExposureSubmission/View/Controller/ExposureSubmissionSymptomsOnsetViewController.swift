//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionSymptomsOnsetViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		onPrimaryButtonTap: @escaping (SymptomsOnsetOption, @escaping (Bool) -> Void) -> Void,
		onDismiss: @escaping (@escaping (Bool) -> Void) -> Void
	) {
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss
		super.init(nibName: nil, bundle: nil)
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

	// MARK: - Protocol FooterViewHandling
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard let selectedSymptomsOnsetSelectionOption = selectedSymptomsOnsetOption else {
			fatalError("Primary button must not be enabled before the user has selected an option")
		}

		onPrimaryButtonTap(selectedSymptomsOnsetSelectionOption) { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.view.isUserInteractionEnabled = !isLoading
				self?.parent?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
				self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
			}
		}
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.view.isUserInteractionEnabled = !isLoading
				self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
			}
		}
	}
	
	// MARK: - Internal
	
	enum SymptomsOnsetOption {
		case exactDate(Date)
		case lastSevenDays
		case oneToTwoWeeksAgo
		case moreThanTwoWeeksAgo
		case preferNotToSay
	}

	// MARK: - Private

	private let onPrimaryButtonTap: (SymptomsOnsetOption, @escaping (Bool) -> Void) -> Void
	private let onDismiss: (@escaping (Bool) -> Void) -> Void
	
	private var symptomsOnsetButtonStateSubscription: AnyCancellable?
	private var optionGroupSelectionSubscription: AnyCancellable?

	@OpenCombine.Published private var selectedSymptomsOnsetOption: SymptomsOnsetOption?

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

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		
		parent?.navigationItem.title = AppStrings.ExposureSubmissionSymptomsOnset.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		
		setupTableView()

		symptomsOnsetButtonStateSubscription = $selectedSymptomsOnsetOption.receive(on: RunLoop.main.ocombine).sink { [weak self] in
			self?.footerView?.setLoadingIndicator(false, disable: $0 == nil, button: .primary)
		}
	}

	private func setupTableView() {
		tableView.separatorStyle = .none

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
