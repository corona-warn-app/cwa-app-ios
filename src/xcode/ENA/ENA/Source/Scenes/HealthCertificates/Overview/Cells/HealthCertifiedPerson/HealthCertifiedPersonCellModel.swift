////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonCellModel {

	// MARK: - Init

	init?(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		guard let mostRelevantCertificate = healthCertifiedPerson.healthCertificates.mostRelevant else {
			Log.error("failed to get mostRelevant health certificate")
			return nil
		}
		title = AppStrings.HealthCertificate.Overview.VaccinationCertificate.title
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.name?.fullName
		certificate = mostRelevantCertificate
		description = AppStrings.HealthCertificate.Overview.covidCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell
	}

	init(
		testCertificate: HealthCertificate
	) {
		title = AppStrings.HealthCertificate.Overview.TestCertificate.title
		backgroundGradientType = .lightBlue(withStars: false)
		name = testCertificate.name.fullName
		certificate = testCertificate
		description = AppStrings.HealthCertificate.Overview.covidCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell
	}

	// MARK: - Internal

	let title: String
	let name: String?
	let description: String
	let accessibilityIdentifier: String
	let certificate: HealthCertificate
	let backgroundGradientType: GradientView.GradientType
}
