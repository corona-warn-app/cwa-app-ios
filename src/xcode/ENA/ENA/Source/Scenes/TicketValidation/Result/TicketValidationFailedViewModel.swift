//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct TicketValidationFailedViewModel: TicketValidationResultViewModel {

	// MARK: - Init

	init(
		validationDate: Date,
		serviceProvider: String,
		validationResultItems: [TicketValidationResultToken.ResultItem]
	) {
		self.validationDate = validationDate
		self.serviceProvider = serviceProvider
		self.validationResultItems = validationResultItems
	}

	// MARK: - Protocol TicketValidationResultViewModel

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = [
			.headlineWithImage(
				headerText: AppStrings.TicketValidation.Result.Failed.title,
				image: UIImage(imageLiteralResourceName: "Illu_Validation_Invalid"),
				imageAccessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.ValidationResult.Failed.headerImageWithTitle
			),
			.footnote(
				text: String(
					format: AppStrings.TicketValidation.Result.validationParameters,
					DateFormatter.localizedString(from: validationDate, dateStyle: .short, timeStyle: .short)
				),
				color: .enaColor(for: .textPrimary2)
			),
			.title2(
				text: AppStrings.TicketValidation.Result.Failed.subtitle,
				accessibilityIdentifier: AccessibilityIdentifiers.TicketValidation.ValidationResult.Failed.subtitle
			),
			.body(
				text: String(
					format: AppStrings.TicketValidation.Result.Failed.description,
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

	private let validationDate: Date
	private let serviceProvider: String
	private let validationResultItems: [TicketValidationResultToken.ResultItem]

}
