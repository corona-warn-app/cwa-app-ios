//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class SRSTestTypeSelectionViewModel {
	
	// MARK: - Init
	
	init(submissionTypeToPreselect: SRSSubmissionType? = nil) {
		self.submissionTypeToPreselect = submissionTypeToPreselect
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		.init([
			.section(
				header: .none,
				footer: .none,
				separators: .none,
				isHidden: nil,
				background: .none,
				cells: [
					.body(
						text: AppStrings.ExposureSubmission.SRSTestTypeSelection.body,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.body
					),
					.footnote(
						text: AppStrings.ExposureSubmission.SRSTestTypeSelection.description,
						color: .enaColor(for: .textPrimary2),
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.description
					),
					.custom(
						withIdentifier: SRSTestTypeSelectionViewController.CustomCellReuseIdentifiers.optionGroupCell,
						configure: { _, cell, _ in
							guard let cell = cell as? DynamicTableViewOptionGroupCell else {
								return
							}
							
							let options: [OptionGroupViewModel.Option] = self.submissionTypes
								.map {
									(title: $0.optionTitle, accessibilityIdentifier: $0.optionAccessibilityIdentifier)
								}
								.filter {
									!$0.title.isEmpty
								}
								.map {
									.option(
										title: $0.title,
										accessibilityIdentifier: $0.accessibilityIdentifier
									)
								}
							
							cell.configure(
								options: options,
								initialSelection: self.initialSelection
							)
							
							self.optionGroupSelectionSubscription = cell.$selection.sink {
								guard case let .option(index) = $0 else { return }
								self.selectedSubmissionType = self.submissionTypes[index]
							}
						})
				]
			)
		])
	}
	
	/// The `SAP_Internal_SubmissionPayload.SubmissionType` that the user has selected in the list.
	/// Is `nil`, as long as the user hasn't made a selection.
	@OpenCombine.Published var selectedSubmissionType: SRSSubmissionType?
	
	// MARK: - Private

	/// The order of the list entries shown.
	private let submissionTypes: [SRSSubmissionType] = [
		.srsRegisteredRat,
		.srsUnregisterdRat,
		.srsRegisteredPcr,
		.srsUnregisteredPcr,
		.srsRapidPcr,
		.srsOther
	]
	
	private var optionGroupSelectionSubscription: AnyCancellable?
	
	private let submissionTypeToPreselect: SRSSubmissionType?
	
	private var initialSelection: OptionGroupViewModel.Selection? {
		if let submissionTypeToPreselect = submissionTypeToPreselect, let index = submissionTypes.firstIndex(of: submissionTypeToPreselect) {
			return .option(index: index)
		} else {
			return nil
		}
	}
}

fileprivate extension SRSSubmissionType {
	var optionTitle: String {
		switch self {
		case .srsSelfTest:
			// This case "srsSelfTest" which is not shown in the test selection screen
			// so we don't need a string to show on the screen
			return ""
		case .srsRegisteredRat:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSRegisteredRatTitle
		case .srsUnregisterdRat:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSUnregisteredRatTitle
		case .srsRegisteredPcr:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSRegisteredPcrTitle
		case .srsUnregisteredPcr:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSUnregisteredPcrTitle
		case .srsRapidPcr:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSRapidPcrTitle
		case .srsOther:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSOtherTitle
		}
	}
	
	var optionAccessibilityIdentifier: String? {
		switch self {
		case .srsSelfTest:
			// This case "srsSelfTest" which is not shown in the test selection screen
			// so we don't need an accessibilityIdentifier
			return nil
		case .srsUnregisterdRat:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSUnregisteredRat
		case .srsRegisteredRat:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSRegisteredRat
		case .srsRegisteredPcr:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSRegisteredPcr
		case .srsUnregisteredPcr:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSUnregisteredPcr
		case .srsRapidPcr:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSRapidPcr
		case .srsOther:
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSOther
		}
	}
}
