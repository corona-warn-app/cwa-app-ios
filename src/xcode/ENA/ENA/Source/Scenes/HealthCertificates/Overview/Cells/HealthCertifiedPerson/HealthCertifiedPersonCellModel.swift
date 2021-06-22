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
		title = AppStrings.HealthCertificate.Overview.covidTitle
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.name?.fullName
		certificate = mostRelevantCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell
	}

	// - remove later
	init(
		testCertificate: HealthCertificate
	) {
		title = AppStrings.HealthCertificate.Overview.covidTitle
		backgroundGradientType = .lightBlue(withStars: true)
		name = testCertificate.name.fullName
		certificate = testCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell
	}

	// MARK: - Internal
	
	let title: String
	let name: String?
	let accessibilityIdentifier: String
	let certificate: HealthCertificate
	let backgroundGradientType: GradientView.GradientType
}
