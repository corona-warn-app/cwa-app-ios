//
// 🦠 Corona-Warn-App
//

import UIKit

struct SecondTicketValidationConsentViewModel {
	
	init(
		serviceIdentity: String,
		serviceProvider: String,
		healthCertificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson,
		onDataPrivacyTap: @escaping () -> Void
	) {
		self.serviceIdentity = serviceIdentity
		self.serviceProvider = serviceProvider
		self.healthCertificate = healthCertificate
		self.healthCertifiedPerson = healthCertifiedPerson
		self.onDataPrivacyTap = onDataPrivacyTap
	}

	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		
		DynamicTableViewModel([
			// HealthCertificate
			.section(
				cells: [
					.identifier(
						SecondTicketValidationConsentViewController.CustomCellReuseIdentifiers.healthCertificateCell,
						configure: { _, cell, _ in
							guard let cell = cell as? HealthCertificateCell else {
								fatalError("could not initialize cell of type `HealthCertificateCell`")
							}
							
							cell.configure(
								HealthCertificateCellViewModel(
									healthCertificate: healthCertificate,
									healthCertifiedPerson: healthCertifiedPerson,
									details: .overview
								),
								withDisclosureIndicator: false
							)
						}
					)
				]
			),
			// Subtitle with serviceIdentity and serviceProvider
			.section(
				cells: [
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
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
					.legalExtendedTicketValidation(
						title: NSAttributedString(
							string: AppStrings.TicketValidation.SecondConsent.Legal.title
						),
						description: NSAttributedString(
							string: AppStrings.TicketValidation.SecondConsent.Legal.subtitle,
							attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
						),
						bulletPoints: [
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.bulletPoint1),
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.bulletPoint2)
						],
						subBulletPoints: [
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.subBulletPoint1),
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.subBulletPoint2),
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.subBulletPoint3),
							NSAttributedString(string: AppStrings.TicketValidation.SecondConsent.Legal.subBulletPoint4)
						],
						accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.SecondConsent.legalBox,
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
						text: AppStrings.TicketValidation.SecondConsent.bulletPoint1
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.SecondConsent.bulletPoint2
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.SecondConsent.bulletPoint3
					),
					.space(
						height: 20
					),
					.bulletPoint(
						text: AppStrings.TicketValidation.SecondConsent.bulletPoint4
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
						text: AppStrings.TicketValidation.SecondConsent.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.SecondConsent.dataPrivacy,
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
	private let serviceIdentity: String
	private let healthCertificate: HealthCertificate
	private let healthCertifiedPerson: HealthCertifiedPerson
	private let onDataPrivacyTap: () -> Void
}

internal extension DynamicCell {

	/// A `legalExtendedTicketValidation` to display legal text for Ticket Validation consent screen with bullet points and sub bullet points
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - description: Optional description text.
	///   - bulletPoints: A list of strings to be prefixed with bullet points.
	///   - subBulletPoints: A list of strings to be prefixed with tiny little bullet points
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display legal texts
	static func legalExtendedTicketValidation(
		title: NSAttributedString,
		description: NSAttributedString,
		bulletPoints: [NSAttributedString],
		subBulletPoints: [NSAttributedString],
		accessibilityIdentifier: String,
		configure: @escaping CellConfigurator
	) -> Self {
		.identifier(SecondTicketValidationConsentViewController.CustomCellReuseIdentifiers.legalExtended) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalExtendedCell else {
				fatalError("could not initialize cell of type `DynamicLegalExtendedCell`")
			}
			cell.configure(
				title: title,
				description: description,
				bulletPoints: bulletPoints,
				subBulletPoints: subBulletPoints,
				accessibilityIdentifier: accessibilityIdentifier
			)
			configure(viewController, cell, indexPath)
		}
	}
}
