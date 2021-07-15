//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct HealthCertificateTechnicalValidationFailedViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Init

	init(arrivalCountry: Country, arrivalDate: Date) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.Validation.Result.Failed.title,
						image: UIImage(imageLiteralResourceName: "Illu_Validation_Invalid")
					),
					.footnote(
						text: String(
							format: AppStrings.HealthCertificate.Validation.Result.validationParameters,
							arrivalCountry.localizedName,
							DateFormatter.localizedString(from: arrivalDate, dateStyle: .short, timeStyle: .short),
							DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
						),
						color: .enaColor(for: .textPrimary2)
					),
					.title2(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.subtitle),
					.space(height: 10),
					.headline(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.failedSectionTitle),
					.body(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.failedSectionDescription),
					.technicalFailedRulesCell(),
					.textWithLinks(
						text: String(
							format: AppStrings.HealthCertificate.Validation.Result.moreInformation,
							AppStrings.HealthCertificate.Validation.Result.moreInformationPlaceholderFAQ, AppStrings.Links.healthCertificateValidationEU),
						links: [
							AppStrings.HealthCertificate.Validation.Result.moreInformationPlaceholderFAQ: AppStrings.Links.healthCertificateValidationFAQ,
							AppStrings.Links.healthCertificateValidationEU: AppStrings.Links.healthCertificateValidationEU
						],
						linksColor: .enaColor(for: .textTint)
					)
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date

}

private extension DynamicCell {

	static func technicalFailedRulesCell() -> Self {
		.custom(withIdentifier: TechnicalValidationFailedRulesTableViewCell.dynamicTableViewCellReuseIdentifier)
	}

}
