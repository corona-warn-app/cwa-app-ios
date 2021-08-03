//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct HealthCertificateValidationPassedViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Init

	init(
		arrivalCountry: Country,
		arrivalDate: Date,
		validationResults: [ValidationResult]
	) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
		self.validationResults = validationResults
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
					.body(
						text: String(
							format: AppStrings.HealthCertificate.Validation.Result.Passed.description,
							validationResults.filter({ validationResult in
								validationResult.rule?.ruleType == .acceptence
							}).count
						)
					),
					.space(height: 12),
					.headline(text: AppStrings.HealthCertificate.Validation.Result.Passed.hintsTitle),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint1, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint2, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint3, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint4, spacing: .large),
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
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let validationResults: [ValidationResult]

}
