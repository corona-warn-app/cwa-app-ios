////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

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
				  fatalError("Cell cannot be shown if person is not vaccinated")
		}

		return String(
			format: AppStrings.HealthCertificate.Person.VaccinationHint.daysSinceLastVaccination,
			daysSinceLastVaccination
		)
	}

	var description: String {
		if let boosterRule = healthCertifiedPerson.boosterRule {
			return "\(boosterRule.localizedDescription) (\(boosterRule.identifier))"
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

	// MARK: - Private

	let healthCertifiedPerson: HealthCertifiedPerson

}
