////
// 🦠 Corona-Warn-App
//

import UIKit
import OrderedCollections
import OpenCombine

class HealthCertifiedPersonCellModel {

	// MARK: - Init

	init?(
		healthCertifiedPerson: HealthCertifiedPerson,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		guard let mostRelevantCertificate = healthCertifiedPerson.mostRelevantHealthCertificate else {
			Log.error("failed to get mostRelevant health certificate")
			return nil
		}

		backgroundGradientType = healthCertifiedPerson.gradientType

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = healthCertifiedPerson.name?.fullName

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: mostRelevantCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			imageAccessibilityTraits: [.image, .button],
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription,
			covPassCheckInfoPosition: .bottom,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		if healthCertifiedPerson.unseenNewsCount > 0 {
			self.caption = .unseenNews(count: healthCertifiedPerson.unseenNewsCount)
		} else if !mostRelevantCertificate.isConsideredValid {
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
			case .blocked:
				self.caption = .validityState(
					image: UIImage(named: "Icon_ExpiredInvalid"),
					description: AppStrings.HealthCertificate.ValidityState.blocked
				)
			}
		} else {
			self.caption = nil
		}

		isStatusTitleVisible = !(healthCertifiedPerson.dccWalletInfo?.admissionState.badgeText?.localized() ?? "").isEmpty

		if let certificates = healthCertifiedPerson.dccWalletInfo?.verification.certificates, certificates.count >= 2 {
			switchableHealthCertificates = certificates.reduce(into: OrderedDictionary<String, HealthCertificate>()) {
				if let certificate = healthCertifiedPerson.healthCertificate(for: $1.certificateRef), let buttonText = $1.buttonText.localized() {
					$0[buttonText] = certificate
				}
			}
		} else {
			switchableHealthCertificates = [:]
		}

		shortStatus = healthCertifiedPerson.dccWalletInfo?.admissionState.badgeText?.localized()
	}

	init?(
		decodingFailedHealthCertificate: DecodingFailedHealthCertificate,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		backgroundGradientType = .solidGrey

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = ""

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			base45: decodingFailedHealthCertificate.base45,
			shouldBlockCertificateCode: false,
			imageAccessibilityTraits: .image,
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription,
			covPassCheckInfoPosition: .bottom,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		self.caption = .validityState(
			image: UIImage(named: "Icon_ExpiredInvalid"),
			description: "\(String(describing: decodingFailedHealthCertificate.error))"
		)

		isStatusTitleVisible = false
		shortStatus = nil

		switchableHealthCertificates = [:]
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

	let isStatusTitleVisible: Bool
	let shortStatus: String?

	let switchableHealthCertificates: OrderedDictionary<String, HealthCertificate>

	func showHealthCertificate(at index: Int) {
		qrCodeViewModel.updateImage(with: switchableHealthCertificates.elements[index].value)
	}

}
