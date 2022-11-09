//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class TestTypeSelectionViewModel {
	
	// MARK: - Init
	
	init(preSelectSelfTest: Bool) {
		isInitialSelectionSelfTestSubmissionType = preSelectSelfTest
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
						text: AppStrings.ExposureSubmission.TestTypeSelection.body,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.body
					),
					.custom(
						withIdentifier: ExposureSubmissionSymptomsViewController.CustomCellReuseIdentifiers.optionGroupCell,
						configure: { _, cell, _ in
							guard let cell = cell as? DynamicTableViewOptionGroupCell else {
								return
							}
							
							let options: [OptionGroupViewModel.Option] = self.submissionTypeForChoosing
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
								self.selectedSubmissionType = self.submissionTypeForChoosing[index]
							}
						})
				]
			)
		])
	}
	
	/// The `SAP_Internal_SubmissionPayload.SubmissionType` that the user has selected in the list.
	/// Is `nil`, as long as the user hasn't made a selection.
	@OpenCombine.Published var selectedSubmissionType: SAP_Internal_SubmissionPayload.SubmissionType?
	
	// MARK: - Private

	/// The order of the list entries shown.
	private let submissionTypeForChoosing: [SAP_Internal_SubmissionPayload.SubmissionType] = [
		.srsRegisteredRat,
		.srsSelfTest,
		.srsRegisteredPcr,
		.srsUnregisteredPcr,
		.srsRapidPcr,
		.srsOther
	]
	
	private var optionGroupSelectionSubscription: AnyCancellable?
	
	private let isInitialSelectionSelfTestSubmissionType: Bool
	
	private var initialSelection: OptionGroupViewModel.Selection? {
		if isInitialSelectionSelfTestSubmissionType, let index = submissionTypeForChoosing.firstIndex(of: .srsSelfTest) {
			return .option(index: index)
		} else {
			return nil
		}
	}
}

fileprivate extension SAP_Internal_SubmissionPayload.SubmissionType {
	var optionTitle: String {
		switch self {
		case .srsSelfTest:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSSelfTestTitle
		case .srsRegisteredRat:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSRegisteredRatTitle
		case .srsRegisteredPcr:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSRegisteredPcrTitle
		case .srsUnregisteredPcr:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSUnregisteredPcrTitle
		case .srsRapidPcr:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSRapidPcrTitle
		case .srsOther:
			return AppStrings.ExposureSubmission.TestTypeSelection.optionSRSOtherTitle
		default:
			return ""
		}
	}
	
	var optionAccessibilityIdentifier: String? {
		switch self {
		case .srsSelfTest:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSSelfTest
		case .srsRegisteredRat:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSRegisteredRat
		case .srsRegisteredPcr:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSRegisteredPcr
		case .srsUnregisteredPcr:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSUnregisteredPcr
		case .srsRapidPcr:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSRapidPcr
		case .srsOther:
			return AccessibilityIdentifiers.ExposureSubmission.TestTypeSelection.optionSRSOther
		default:
			return nil
		}
	}
}
