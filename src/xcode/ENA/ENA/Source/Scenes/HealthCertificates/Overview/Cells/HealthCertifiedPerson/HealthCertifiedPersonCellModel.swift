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
		name = healthCertifiedPerson.name?.fullName
		qrCodeImage = mostRelevantCertificate.qrCodeImage
		backgroundGradientType = healthCertifiedPerson.gradientType
	}

	// MARK: - Internal
	
	let title: String
	let name: String?
	let qrCodeImage: UIImage?
	let backgroundGradientType: GradientView.GradientType

}
