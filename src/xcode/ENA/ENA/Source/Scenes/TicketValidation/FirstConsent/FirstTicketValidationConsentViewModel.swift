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
			// Image with title
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.TicketValidation.FirstConsent.title,
						image: UIImage(imageLiteralResourceName: "Illu_TicketValidation"),
						imageAccessibilityLabel: AppStrings.TicketValidation.FirstConsent.imageDescription,
						imageAccessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.image
					)
				]
			),
			// Subtitle with service provider and subject
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
			// Bulletpoints in consent box
			.section(
				cells: [
					.acknowledgement(
						title: NSAttributedString(
							string: AppStrings.TicketValidation.FirstConsent.Legal.title
						),
						description: NSAttributedString(
							string: AppStrings.TicketValidation.FirstConsent.Legal.subtitle,
							attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
						),
						bulletPoints: [
							NSAttributedString(string: AppStrings.TicketValidation.FirstConsent.Legal.bulletPoint1),
							NSAttributedString(string: AppStrings.TicketValidation.FirstConsent.Legal.bulletPoint2)
						],
						accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.legalBox,
						configure: { _, cell, _ in
							cell.backgroundColor = .enaColor(for: .background)
						}
					)
				]
			),
			// Bulletpoints without box
			.section(
				cells: [
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.FirstConsent.bulletPoint1
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.FirstConsent.bulletPoint2
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.FirstConsent.bulletPoint3
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.FirstConsent.bulletPoint4
					),
					.space(
						height: 20
					)
				]
			),
			
			// Data privacy cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.TicketValidation.FirstConsent.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.FirstConsent.dataPrivacy,
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
