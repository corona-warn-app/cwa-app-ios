//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

final class TestResultAvailableViewModel {

	// MARK: - Init

	init(
		exposureSubmissionService: ExposureSubmissionService,
		didTapConsentCell: @escaping () -> Void,
		didTapPrimaryFooterButton: @escaping () -> Void,
		presentDismissAlert: @escaping () -> Void
	) {
		self.exposureSubmissionService = exposureSubmissionService
		self.didTapConsentCell = didTapConsentCell
		self.didTapPrimaryFooterButton = didTapPrimaryFooterButton
		self.presentDismissAlert = presentDismissAlert

		exposureSubmissionService.isSubmissionConsentGivenPublisher.sink { [weak self] newValue in
			self?.currentState = newValue ?
				AppStrings.ExposureSubmissionTestresultAvailable.consentGranted :
				AppStrings.ExposureSubmissionTestresultAvailable.consentNotGranted
			self?.refreshTableView?()
		}.store(in: &cancellables)
	}

	// MARK: - Internal

	let didTapPrimaryFooterButton: () -> Void
	let presentDismissAlert: () -> Void
	var currentState: String = AppStrings.ExposureSubmissionTestresultAvailable.consentNotGranted
	var refreshTableView: (() -> Void)?

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(
					UIImage(named: "Illu_Testresult_available"),
					accessibilityLabel: AppStrings.ExposureSubmissionTestresultAvailable.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.General.image
				),
				separators: .none,
				cells: []
			),
			.section(
				separators: .all,
				cells: [
					.icon(UIImage(named: "Icons_Grey_Warnen"),
						  text: .string(currentState),
						  action: .execute { [weak self] _, _ in
							self?.didTapConsentCell()
						  },
						  configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
						  }
					)
				]
			),
			.section(
				separators: .none,
				cells: [
				   .body(text: AppStrings.ExposureSubmissionTestresultAvailable.listItem1),
				   .headline(text: AppStrings.ExposureSubmissionTestresultAvailable.listItem2)
			   ]
			)

		])
	}

	// MARK: - Private

	private let exposureSubmissionService: ExposureSubmissionService
	private var cancellables: Set<AnyCancellable> = []
	private let didTapConsentCell: () -> Void

}
