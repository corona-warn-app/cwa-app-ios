////
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
		validationResults: [ValidationResult]
	) {
		self.arrivalCountry = arrivalCountry
		self.arrivalDate = arrivalDate
		self.validationResults = validationResults
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = [
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

		// TODO: Open Validation Results

		cells.append(.body(text: AppStrings.HealthCertificate.Validation.Result.moreInformation))

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

	private var openValidationResults: [ValidationResult] {
		openAcceptanceRuleValidationResults + openInvalidationRuleValidationResults
	}

	private var openAcceptanceRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .acceptence && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

	private var openInvalidationRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .invalidation && $0.result == .open }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

}
