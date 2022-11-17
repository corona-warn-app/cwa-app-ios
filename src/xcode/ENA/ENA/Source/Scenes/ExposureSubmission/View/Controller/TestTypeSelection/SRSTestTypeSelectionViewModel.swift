//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class SRSTestTypeSelectionViewModel {
	
	// MARK: - Init
	
	init(isSelfTestTypePreselected: Bool) {
		isSelfTestTypePreSelected = isSelfTestTypePreselected
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
		.srsSelfTest,
		.srsRegisteredPcr,
		.srsUnregisteredPcr,
		.srsRapidPcr,
		.srsOther
	]
	
	private var optionGroupSelectionSubscription: AnyCancellable?
	
	private let isSelfTestTypePreSelected: Bool
	
	private var initialSelection: OptionGroupViewModel.Selection? {
		if isSelfTestTypePreSelected, let index = submissionTypes.firstIndex(of: .srsSelfTest) {
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
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSSelfTestTitle
		case .srsRegisteredRat:
			return AppStrings.ExposureSubmission.SRSTestTypeSelection.optionSRSRegisteredRatTitle
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
			return AccessibilityIdentifiers.ExposureSubmission.SRSTestTypeSelection.optionSRSSelfTest
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
