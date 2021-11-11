//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct FirstTicketValidationConsentViewModel {

	init(
		initializationData: TicketValidationInitializationData,
		onDataPrivacyTap: @escaping () -> Void
	) {
		self.initializationData = initializationData
		self.onDataPrivacyTap = onDataPrivacyTap
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			// Data privacy cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ContactDiary.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in
							onDataPrivacyTap()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
		])
	}

	// MARK: - Private

	private let initializationData: TicketValidationInitializationData
	private let onDataPrivacyTap: () -> Void

}
