//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct TicketValidationPassedViewModel: TicketValidationResultViewModel {

	// MARK: - Init

	init(
		serviceProvider: String
	) {
		self.serviceProvider = serviceProvider
	}

	// MARK: - Protocol TicketValidationResultViewModel

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.TicketValidation.Result.Passed.title,
						image: UIImage(imageLiteralResourceName: "Illu_Validation_Valid")
					),
					.footnote(
						text: String(
							format: AppStrings.TicketValidation.Result.validationParameters,
							DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
						),
						color: .enaColor(for: .textPrimary2)
					),
					.title2(
						text: AppStrings.TicketValidation.Result.Passed.subtitle
					),
					.body(
						text: String(
							format: AppStrings.TicketValidation.Result.Passed.description,
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
			)
		])
	}

	// MARK: - Private

	private let serviceProvider: String

}
