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
		self.serviceProvider = "Lufthansa"
		self.subject = "Flug LH 3243"
		self.onDataPrivacyTap = onDataPrivacyTap
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			// image with title
			.section(
				header: .image(
					UIImage(named: "Illu_TicketValidation"),
					title: AppStrings.TicketValidation.FirstConsent.title,
					accessibilityLabel: AppStrings.TicketValidation.FirstConsent.imageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.image
				),
				cells: []
			),
			// subtitle with service provider and subject
			.section(
				cells: [
					.title2(
						text: AppStrings.TicketValidation.FirstConsent.subtitle
					),
					.footnote(
						text: AppStrings.TicketValidation.FirstConsent.serviceProvider,
						color: .enaColor(for: .textPrimary2)
					),
					.bodyWithoutTopInset(
						text: String(
							format: AppStrings.TicketValidation.FirstConsent.serviceProviderValue,
							serviceProvider
						)
					),
					.footnote(
						text: AppStrings.TicketValidation.FirstConsent.subject,
						color: .enaColor(for: .textPrimary2)
					),
					.bodyWithoutTopInset(
						text: String(
							format: AppStrings.TicketValidation.FirstConsent.subjectValue,
							subject
						)
					),
					.body(
						text: AppStrings.TicketValidation.FirstConsent.explination
					)
				]
			),
			// bulletpoints in consent box
			.section(
				cells: [
					.legalExtendedDataDonation(
						title: NSAttributedString(
							string: AppStrings.TicketValidation.FirstConsent.legalTitle
						),
						description: NSAttributedString(
							string: AppStrings.TicketValidation.FirstConsent.legalSubtitle,
							attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
						),
						bulletPoints: [
							NSAttributedString(string: AppStrings.TicketValidation.FirstConsent.legalBulletPoint1),
							NSAttributedString(string: AppStrings.TicketValidation.FirstConsent.legalBulletPoint2)
						],
						accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox,
						configure: { _, cell, _ in
							cell.backgroundColor = .enaColor(for: .background)
						}
					)
				]
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
						}
					)
				]
			)
		])
	}
	
	// MARK: - Private
	
	private let serviceProvider: String
	private let subject: String
	private let onDataPrivacyTap: () -> Void
	
}
