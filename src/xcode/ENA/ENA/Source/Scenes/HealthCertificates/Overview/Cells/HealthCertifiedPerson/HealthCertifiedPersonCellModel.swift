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

		backgroundGradientType = healthCertifiedPerson.gradientType

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = healthCertifiedPerson.name?.fullName

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: mostRelevantCertificate,
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription
		)

		if mostRelevantCertificate.validityState == .invalid ||
			(mostRelevantCertificate.type != .test && mostRelevantCertificate.validityState != .valid) {
			switch mostRelevantCertificate.validityState {
			case .valid:
				self.validityStateIcon = nil
				self.validityStateTitle = nil
			case .expiringSoon:
				self.validityStateIcon = UIImage(named: "Icon_ExpiringSoon")
				self.validityStateTitle = String(
					format: AppStrings.HealthCertificate.ValidityState.expiringSoon,
					DateFormatter.localizedString(from: mostRelevantCertificate.expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: mostRelevantCertificate.expirationDate, dateStyle: .none, timeStyle: .short)
				)
			case .expired:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.expired
			case .invalid:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.invalid
			}
		} else {
			self.validityStateIcon = nil
			self.validityStateTitle = nil
		}
	}

	// MARK: - Internal

	let backgroundGradientType: GradientView.GradientType
	
	let title: String
	let name: String?

	let qrCodeViewModel: HealthCertificateQRCodeViewModel

	let validityStateIcon: UIImage?
	let validityStateTitle: String?

}
