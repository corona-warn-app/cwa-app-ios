////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		title = AppStrings.HealthCertificate.Overview.VaccinationCertificate.title
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.name?.fullName

		switch healthCertifiedPerson.vaccinationState {
		case .partiallyVaccinated:
			description = AppStrings.HealthCertificate.Overview.VaccinationCertificate.partiallyVaccinated
		case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
			description = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			)
		case .completelyProtected(let expirationDate):
			description = String(
				format: AppStrings.HealthCertificate.Overview.VaccinationCertificate.vaccinationValidUntil,
				DateFormatter.localizedString(from: expirationDate, dateStyle: .medium, timeStyle: .none)
			)
		}

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell
	}

	init(
		testCertificate: HealthCertificate
	) {
		title = AppStrings.HealthCertificate.Overview.TestCertificate.title
		backgroundGradientType = .lightBlue(withStars: false)
		name = testCertificate.name.fullName

		if let sampleCollectionDate = testCertificate.testEntry?.sampleCollectionDate {
			description = String(
				format: AppStrings.HealthCertificate.Overview.TestCertificate.testDate,
				DateFormatter.localizedString(from: sampleCollectionDate, dateStyle: .medium, timeStyle: .short)
			)
		} else {
			description = nil
		}

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell
	}

	// MARK: - Internal

	let title: String
	let name: String?
	let description: String?
	let accessibilityIdentifier: String?
	
	var backgroundGradientType: GradientView.GradientType = .solidGrey
}
