//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct SecondTicketValidationConsentViewModel {
	
	init(
		serviceIdentity: String,
		serviceProvider: String,
		healthCertificate: HealthCertificate,
		onDataPrivacyTap: @escaping () -> Void
	) {
		self.serviceIdentity = serviceIdentity
		self.serviceProvider = serviceProvider
		self.healthCertificate = healthCertificate
		self.onDataPrivacyTap = onDataPrivacyTap
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		
		DynamicTableViewModel([
			// HealthCertificate
			
			// Subtitle with serviceIdentity and serviceProvider
			.section(
				cells: [
					.title2(
						text: AppStrings.TicketValidation.SecondConsent.subtitle
					),
					.footnote(
						text: AppStrings.TicketValidation.SecondConsent.serviceIdentity,
						color: .enaColor(for: .textPrimary2)
					),
					.bodyWithoutTopInset(
						text: String(
							format: AppStrings.TicketValidation.SecondConsent.serviceIdentityValue,
							serviceIdentity
						)
					),
					.footnote(
						text: AppStrings.TicketValidation.SecondConsent.serviceProvider,
						color: .enaColor(for: .textPrimary2)
					),
					.bodyWithoutTopInset(
						text: String(
							format: AppStrings.TicketValidation.SecondConsent.serviceProviderValue,
							serviceProvider
						)
					),
					.body(
						text: AppStrings.TicketValidation.SecondConsent.explination
					)
				]
			),
			// Bulletpoints in consent box
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
	
	private let serviceIdentity: String
	private let serviceProvider: String
	private let healthCertificate: HealthCertificate
	private let onDataPrivacyTap: () -> Void
}
