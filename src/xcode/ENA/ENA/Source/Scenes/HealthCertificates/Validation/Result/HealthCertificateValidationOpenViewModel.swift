//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct HealthCertificateValidationOpenViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Init

	init(
		arrivalCountry: Country,
		arrivalDate: Date,
		validationResults: [ValidationResult],
		healthCertificate: HealthCertificate,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding
	) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
		self.validationResults = validationResults
		self.healthCertificate = healthCertificate
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}

	// MARK: - Internal
	
	// Internal for testing purposes
	var openValidationResults: [ValidationResult] {
		openAcceptanceRuleValidationResults + openInvalidationRuleValidationResults
	}
	
	// Internal for testing purposes
	var openAcceptanceRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .acceptence && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

	// Internal for testing purposes
	var openInvalidationRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .invalidation && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = [
			.headlineWithImage(
				headerText: AppStrings.HealthCertificate.Validation.Result.Open.title,
				image: UIImage(imageLiteralResourceName: "Illu_Validation_Unknown")
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
			.title2(text: AppStrings.HealthCertificate.Validation.Result.Open.subtitle),
			.space(height: 10),
			.headline(text: AppStrings.HealthCertificate.Validation.Result.Open.openSectionTitle),
			.body(text: AppStrings.HealthCertificate.Validation.Result.Open.openSectionDescription)
		]

		cells.append(contentsOf: openValidationResults.map { .validationResult($0, healthCertificate: healthCertificate, vaccinationValueSetsProvider: vaccinationValueSetsProvider) })
		cells.append(
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
		)

		return DynamicTableViewModel([
			.section(
				cells: cells
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date
	private let validationResults: [ValidationResult]
	private let healthCertificate: HealthCertificate
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
}
