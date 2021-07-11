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
			.title2(text: AppStrings.HealthCertificate.Validation.Result.Failed.subtitle),
			.space(height: 10),
			.headline(text: AppStrings.HealthCertificate.Validation.Result.Failed.failedSectionTitle),
			.body(text: AppStrings.HealthCertificate.Validation.Result.Failed.failedSectionDescription)
		]

		cells.append(contentsOf: failedValidationResults.map { .validationResult($0) })

		if !openValidationResults.isEmpty {
			cells.append(contentsOf: [
				.space(height: 10),
				.headline(text: AppStrings.HealthCertificate.Validation.Result.Failed.openSectionTitle),
				.body(text: AppStrings.HealthCertificate.Validation.Result.Failed.openSectionDescription)
			])

			cells.append(contentsOf: openValidationResults.map { .validationResult($0) })
		}

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

	private var failedValidationResults: [ValidationResult] {
		failedAcceptanceRuleValidationResults + failedInvalidationRuleValidationResults
	}

	private var failedAcceptanceRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .acceptence && $0.result == .fail }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

	private var failedInvalidationRuleValidationResults: [ValidationResult] {
		validationResults
			.filter { $0.rule?.ruleType == .invalidation && $0.result == .fail }
			.sorted { $0.rule?.identifier ?? "" < $1.rule?.identifier ?? "" }
	}

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
