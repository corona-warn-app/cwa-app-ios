//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct FirstTicketValidationConsentViewModel {

	init(
		serviceProvider: String,
		subject: String,
		onDataPrivacyTap: @escaping () -> Void
	) {
		self.serviceProvider = serviceProvider
		self.subject = subject
		self.onDataPrivacyTap = onDataPrivacyTap
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .image(
					UIImage(named: "Illu_TicketValidation"),
					title: AppStrings.TicketValidation.FirstConsent.title,
					accessibilityLabel: AppStrings.TicketValidation.FirstConsent.imageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.image
				),
				cells: []
			),
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

	private let serviceProvider: String
	private let subject: String
	private let onDataPrivacyTap: () -> Void

}
