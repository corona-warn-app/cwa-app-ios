////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct HealthCertificateValidationFailedViewModel: HealthCertificateValidationResultViewModel {

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
					.footnote(
						text: String(
							format: AppStrings.HealthCertificate.Validation.Result.Passed.validationParameters,
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
					.body(text: AppStrings.HealthCertificate.Validation.Result.Passed.moreInformation)
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let validationResults: [ValidationResult]

}
