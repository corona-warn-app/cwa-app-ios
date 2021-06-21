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
		description = AppStrings.HealthCertificate.Overview.covidCertificate
		backgroundGradientType = healthCertifiedPerson.vaccinationState.gradientType
		name = healthCertifiedPerson.name?.fullName
		certificate = mostRelevantCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.vaccinationCertificateCell
	}

	init(
		testCertificate: HealthCertificate
	) {
		title = AppStrings.HealthCertificate.Overview.covidTitle
		description = AppStrings.HealthCertificate.Overview.covidCertificate
		backgroundGradientType = .lightBlue(withStars: true)
		name = testCertificate.name.fullName
		certificate = testCertificate
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell
	}

	// MARK: - Internal
	
	var attributedText: NSAttributedString {
		let boldTextAttribute: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold),
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textContrast)
		]
		let normalTextAttribute: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: UIFont.enaFont(for: .body),
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textContrast)
		]

		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: description, attributes: normalTextAttribute))
		return bulletPoint
	}

	let title: String
	let name: String?
	let description: String
	let accessibilityIdentifier: String
	let certificate: HealthCertificate
	let backgroundGradientType: GradientView.GradientType
}
