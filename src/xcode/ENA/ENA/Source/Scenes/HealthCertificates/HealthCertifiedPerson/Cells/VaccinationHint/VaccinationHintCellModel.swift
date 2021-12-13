////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit.UIFont

final class VaccinationHintCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
	}

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.Person.VaccinationHint.title

	var subtitle: String? {
		guard let lastVaccinationDate = healthCertifiedPerson.vaccinationCertificates.last?.vaccinationEntry?.localVaccinationDate,
			  let daysSinceLastVaccination = Calendar.autoupdatingCurrent.dateComponents([.day], from: lastVaccinationDate, to: Date()).day else {
				  // Returning nil if the days since last vaccination can't be determined, e.g. in case of an invalid date, like 2021-19-29
				  return nil
		}

		return String(
			format: AppStrings.HealthCertificate.Person.VaccinationHint.daysSinceLastVaccination,
			daysSinceLastVaccination
		)
	}

	var description: String {
		if let boosterRule = healthCertifiedPerson.boosterRule {
			return "\(boosterRule.localizedDescription()) (\(boosterRule.identifier))"
		}

		switch healthCertifiedPerson.vaccinationState {
		case .partiallyVaccinated:
			return AppStrings.HealthCertificate.Person.VaccinationHint.partiallyVaccinated
		case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
			return String(
				format: AppStrings.HealthCertificate.Person.VaccinationHint.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			)
		case .completelyProtected:
			return AppStrings.HealthCertificate.Person.VaccinationHint.completelyProtected
		case .notVaccinated:
			fatalError("Cell cannot be shown if person is not vaccinated")
		}
	}

	var faqLink: NSAttributedString? {
		guard healthCertifiedPerson.boosterRule != nil else {
			return nil
		}

		let text = String(
			format: AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQ,
			AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQPlaceholder
		)

		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: ENAFont.body.textStyle)
				.scaledFont(
					size: ENAFont.body.fontSize,
					weight: ENAFont.body.fontWeight
				),
			.foregroundColor: UIColor.enaColor(for: .textPrimary1)
		]
		let attributedString = NSMutableAttributedString(
			string: text,
			attributes: textAttributes
		)

		attributedString.mark(
			AppStrings.HealthCertificate.Person.VaccinationHint.boosterRuleFAQPlaceholder,
			with: AppStrings.Links.healthCertificateBoosterFAQ
		)

		return attributedString
	}

	var isUnseenNewsIndicatorVisible: Bool {
		healthCertifiedPerson.isNewBoosterRule
	}

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson

}
