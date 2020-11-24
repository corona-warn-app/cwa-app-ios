//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct TestresultAvailableViewModel {

	// MARK: - Init

	init(
		_ store: Store,
		didTapConsentCell: @escaping () -> Void,
		didTapPrimaryFooterButton: @escaping () -> Void,
		presentDismissAlert: @escaping () -> Void
	) {
		self.store = store
		self.didTapConsentCell = didTapConsentCell
		self.didTapPrimaryFooterButton = didTapPrimaryFooterButton
		self.presentDismissAlert = presentDismissAlert
	}

	// MARK: - Internal

	let didTapPrimaryFooterButton: () -> Void
	let presentDismissAlert: () -> Void

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
					.icon(UIImage(named: "Icons_Grey_Warnen"), text: store.isSubmissionConsentGiven ?
							.string(AppStrings.ExposureSubmissionTestresultAvailable.consentGranted) :
							.string(AppStrings.ExposureSubmissionTestresultAvailable.consentNotGranted),
						  action: .execute { _ in
							didTapConsentCell()
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

	private let store: Store
	private let didTapConsentCell: () -> Void

}
