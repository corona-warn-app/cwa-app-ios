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
		cclService: CCLService,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		guard let initialCertificate = Self.initialCertificate(for: healthCertifiedPerson) else {
			Log.error("failed to get initial health certificate")
			return nil
		}

		backgroundGradientType = healthCertifiedPerson.gradientType

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = healthCertifiedPerson.name?.fullName

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: initialCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			imageAccessibilityTraits: [.image, .button],
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription,
			covPassCheckInfoPosition: .bottom,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		if healthCertifiedPerson.unseenNewsCount > 0 {
			self.caption = .unseenNews(count: healthCertifiedPerson.unseenNewsCount)
		} else if !initialCertificate.isConsideredValid {
			self.caption = Self.caption(for: initialCertificate)
		} else {
			self.caption = nil
		}

		if let admissionState = healthCertifiedPerson.dccWalletInfo?.admissionState,
		   admissionState.visible && !(admissionState.badgeText?.localized(cclService: cclService) ?? "").isEmpty {
			isStatusTitleVisible = true
			shortStatus = admissionState.badgeText?.localized(cclService: cclService)
		} else {
			isStatusTitleVisible = false
			shortStatus = nil
		}

		if let certificates = healthCertifiedPerson.dccWalletInfo?.verification.certificates.prefix(2), certificates.count == 2 {
			switchableHealthCertificates = certificates.reduce(into: OrderedDictionary<String, HealthCertificate>()) {
				if let certificate = healthCertifiedPerson.healthCertificate(for: $1.certificateRef) {
					$0[$1.buttonText.localized(cclService: cclService)] = certificate
				}
			}
		} else {
			switchableHealthCertificates = [:]
		}
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

	// MARK: - Private

	private static func initialCertificate(for person: HealthCertifiedPerson) -> HealthCertificate? {
		if let firstVerificationCertificate = person.dccWalletInfo?.verification.certificates.first,
		   let certificate = person.healthCertificate(for: firstVerificationCertificate.certificateRef) {
			return certificate
		} else {
			return person.mostRelevantHealthCertificate
		}
	}

	private static func caption(for certificate: HealthCertificate) -> Caption? {
		switch certificate.validityState {
		case .valid:
			return nil
		case .expiringSoon:
			let validityStateTitle = String(
				format: AppStrings.HealthCertificate.ValidityState.expiringSoon,
				DateFormatter.localizedString(from: certificate.expirationDate, dateStyle: .short, timeStyle: .none),
				DateFormatter.localizedString(from: certificate.expirationDate, dateStyle: .none, timeStyle: .short)
			)

			return .validityState(
				image: UIImage(named: "Icon_ExpiringSoon"),
				description: validityStateTitle
			)
		case .expired:
			return .validityState(
				image: UIImage(named: "Icon_ExpiredInvalid"),
				description: AppStrings.HealthCertificate.ValidityState.expired
			)
		case .invalid:
			return .validityState(
				image: UIImage(named: "Icon_ExpiredInvalid"),
				description: AppStrings.HealthCertificate.ValidityState.invalid
			)
		case .blocked:
			return .validityState(
				image: UIImage(named: "Icon_ExpiredInvalid"),
				description: AppStrings.HealthCertificate.ValidityState.blocked
			)
		}
	}

}
