//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct HealthCertificateTechnicalValidationFailedViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Init

	init(arrivalCountry: Country, arrivalDate: Date, expirationDate: Date?, signatureInvalid: Bool) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
		self.expirationDate = expirationDate
		self.signatureInvalid = signatureInvalid
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		
		DynamicTableViewModel([
			.section(cells: [
				.headlineWithImage(
					headerText: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.title,
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
				.technicalFailedRulesCell(signatureInvalid: signatureInvalid, expirationDate: expirationDate),
				.textWithLinks(
					text: String(
						format: AppStrings.HealthCertificate.Validation.moreInformation,
						AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ, AppStrings.Links.healthCertificateValidationEU),
					links: [
						AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ: AppStrings.Links.healthCertificateValidationFAQ,
						AppStrings.Links.healthCertificateValidationEU: AppStrings.Links.healthCertificateValidationEU
					],
					linksColor: .enaColor(for: .textTint)
				)
			])
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let expirationDate: Date?
	private let signatureInvalid: Bool
}

private extension DynamicCell {

	static func technicalFailedRulesCell(signatureInvalid: Bool, expirationDate: Date?) -> Self {
		.custom(withIdentifier: TechnicalValidationFailedRulesTableViewCell.dynamicTableViewCellReuseIdentifier) { _, cell, _ in
			guard let cell = cell as? TechnicalValidationFailedRulesTableViewCell else {
				return
			}
			cell.customize(signatureInvalid: signatureInvalid, expirationDate: expirationDate)
		}
	}

}
