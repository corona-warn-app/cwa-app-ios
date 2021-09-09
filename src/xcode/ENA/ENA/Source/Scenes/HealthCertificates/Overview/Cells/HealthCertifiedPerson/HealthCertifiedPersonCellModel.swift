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

		if healthCertifiedPerson.unseenNewsCount > 0 {
			self.caption = .unseenNews(count: healthCertifiedPerson.unseenNewsCount)
		} else if mostRelevantCertificate.validityState == .invalid ||
			(mostRelevantCertificate.type != .test && mostRelevantCertificate.validityState != .valid) {
			switch mostRelevantCertificate.validityState {
			case .valid:
				self.caption = nil
			case .expiringSoon:
				let validityStateTitle = String(
					format: AppStrings.HealthCertificate.ValidityState.expiringSoon,
					DateFormatter.localizedString(from: mostRelevantCertificate.expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: mostRelevantCertificate.expirationDate, dateStyle: .none, timeStyle: .short)
				)

				self.caption = .validityState(
					image: UIImage(named: "Icon_ExpiringSoon"),
					description: validityStateTitle
				)
			case .expired:
				self.caption = .validityState(
					image: UIImage(named: "Icon_ExpiredInvalid"),
					description: AppStrings.HealthCertificate.ValidityState.expired
				)
			case .invalid:
				self.caption = .validityState(
					image: UIImage(named: "Icon_ExpiredInvalid"),
					description: AppStrings.HealthCertificate.ValidityState.invalid
				)
			}
		} else {
			self.caption = nil
		}
	}

	init?(
		decodingFailedHealthCertificate: DecodingFailedHealthCertificate
	) {
		backgroundGradientType = .solidGrey(withStars: true)

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = ""

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			base45: decodingFailedHealthCertificate.base45,
			shouldBlockCertificateCode: false,
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription
		)

		self.caption = .validityState(
			image: UIImage(named: "Icon_ExpiredInvalid"),
			description: "\(decodingFailedHealthCertificate.error)"
		)
	}

	// MARK: - Internal

	enum Caption {
		case unseenNews(count: Int)
		case validityState(image: UIImage?, description: String)
	}

	let backgroundGradientType: GradientView.GradientType
	
	let title: String
	let name: String?

	let qrCodeViewModel: HealthCertificateQRCodeViewModel

	let caption: Caption?

}
