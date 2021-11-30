//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct TicketValidationOpenViewModel: TicketValidationResultViewModel {

	// MARK: - Init

	init(
		serviceProvider: String,
		validationResultItems: [TicketValidationResultToken.ResultItem]
	) {
		self.serviceProvider = serviceProvider
		self.validationResultItems = validationResultItems
	}

	// MARK: - Protocol TicketValidationResultViewModel

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = [
			.headlineWithImage(
				headerText: AppStrings.TicketValidation.Result.Open.title,
				image: UIImage(imageLiteralResourceName: "Illu_Validation_Unknown"),
				imageAccessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.ValidationResult.Open.headerImageWithTitle
			),
			.footnote(
				text: String(
					format: AppStrings.TicketValidation.Result.validationParameters,
					DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
				),
				color: .enaColor(for: .textPrimary2)
			),
			.title2(
				text: AppStrings.TicketValidation.Result.Open.subtitle,
				accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.ValidationResult.Open.subtitle
			),
			.body(
				text: String(
					format: AppStrings.TicketValidation.Result.Open.description,
					serviceProvider
				)
			),
			.textWithLinks(
				text: String(
					format: AppStrings.TicketValidation.Result.moreInformation,
					AppStrings.TicketValidation.Result.moreInformationPlaceholderFAQ),
				links: [
					AppStrings.TicketValidation.Result.moreInformationPlaceholderFAQ: AppStrings.Links.ticketValidationServiceResultFAQ
				],
				linksColor: .enaColor(for: .textTint)
			)
		]

		cells.append(contentsOf: validationResultItems.map { .ticketValidationResult($0) })

		return DynamicTableViewModel([
			.section(
				cells: cells
			)
		])
	}

	// MARK: - Private

	private let serviceProvider: String
	private let validationResultItems: [TicketValidationResultToken.ResultItem]

}
