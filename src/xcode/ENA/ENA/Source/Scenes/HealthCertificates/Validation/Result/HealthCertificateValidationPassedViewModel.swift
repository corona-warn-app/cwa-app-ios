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
		let ruleCount = validationResults.filter({ validationResult in
			validationResult.rule?.ruleType == .acceptence
		}).count

		let noRules = ruleCount == 0

		let headlineImage = noRules ?
			UIImage(imageLiteralResourceName: "Illu_Validation_Unknown") :
			UIImage(imageLiteralResourceName: "Illu_Validation_Valid")

		let headerText = noRules ?
			AppStrings.HealthCertificate.Validation.Result.Passed.unknownTitle :
			AppStrings.HealthCertificate.Validation.Result.Passed.title

		let titleText = noRules ?
			AppStrings.HealthCertificate.Validation.Result.Passed.unknownSubtitle :
			AppStrings.HealthCertificate.Validation.Result.Passed.subtitle

		return DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: headerText,
						image: headlineImage
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
					.title2(text: titleText),
					.body(
						text: String(
							format: AppStrings.HealthCertificate.Validation.Result.Passed.description,
							ruleCount
						)
					),
					.textWithLinks(
						text: String(
							format: AppStrings.HealthCertificate.Validation.moreInformation,
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ, AppStrings.Links.healthCertificateValidationEU),
						links: [
							AppStrings.HealthCertificate.Validation.moreInformationPlaceholderFAQ: AppStrings.Links.healthCertificateValidationFAQ,
							AppStrings.Links.healthCertificateValidationEU: AppStrings.Links.healthCertificateValidationEU
						],
						linksColor: .enaColor(for: .textTint)
					),
					.space(height: 8),
					.headline(text: AppStrings.HealthCertificate.Validation.Result.Passed.hintsTitle),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint1, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint2, spacing: .large),
					.bulletPoint(text: AppStrings.HealthCertificate.Validation.Result.Passed.hint4, spacing: .large)
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let validationResults: [ValidationResult]

}
