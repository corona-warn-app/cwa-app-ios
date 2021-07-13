////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct HealthCertificateValidationPassedViewModel: HealthCertificateValidationResultViewModel {

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
						headerText: AppStrings.HealthCertificate.Validation.Result.Passed.title,
						image: UIImage(imageLiteralResourceName: "Illu_Validation_Valid")
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
					.title2(text: AppStrings.HealthCertificate.Validation.Result.Passed.subtitle),
					.space(height: 10),
					.headline(text: AppStrings.HealthCertificate.Validation.Result.Passed.hintsTitle),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint1, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint2, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint3, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint4, spacing: .large),
					.dynamicType(
						text: """
							<p>\(AppStrings.HealthCertificate.Validation.Result.moreInformation01) <a href="\(AppStrings.Links.healthCertificateValidationFAQ)">\(AppStrings.HealthCertificate.Validation.Result.moreInformation02)</a> \(AppStrings.HealthCertificate.Validation.Result.moreInformation03) <a href="\(AppStrings.Links.healthCertificateValidationEU)">\(AppStrings.Links.healthCertificateValidationEU)</a>.</p>
							""",
						cellStyle: .htmlString
					)
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date

}
