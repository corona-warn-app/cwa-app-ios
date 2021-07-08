////
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
					// TODO: Static Expired Cell
					.body(text: AppStrings.HealthCertificate.Validation.Result.moreInformation)
				]
			)
		])
	}

	// MARK: - Private

	private let arrivalCountry: Country
	private let arrivalDate: Date

}
