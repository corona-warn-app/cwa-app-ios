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
		cclService: CCLServable,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		guard let initialCertificate = Self.initialCertificate(for: healthCertifiedPerson) else {
			Log.error("failed to get initial health certificate")
			return nil
		}

		self.healthCertifiedPerson = healthCertifiedPerson
		backgroundGradientType = healthCertifiedPerson.isMaskOptional ? .green : healthCertifiedPerson.gradientType

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = healthCertifiedPerson.name?.fullName

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: initialCertificate,
			showRealQRCodeIfValidityStateBlocked: false,
			imageAccessibilityTraits: [.image, .button],
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription,
			qrCodeAccessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.qrCodeView(of: initialCertificate.uniqueCertificateIdentifier),
			covPassCheckInfoPosition: .bottom,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		if healthCertifiedPerson.unseenNewsCount > 0 {
			self.caption = .unseenNews(count: healthCertifiedPerson.unseenNewsCount)
		} else {
			var shouldShowCaption = false
			
			// Test certificates that are invalid or blocked.
			if initialCertificate.type == .test {
				if initialCertificate.validityState == .invalid || initialCertificate.validityState == .blocked {
					shouldShowCaption = true
				}
			}
			
			// VC or RC certificates, that are not valid or will not expire soon.
			if initialCertificate.type == .vaccination || initialCertificate.type == .recovery {
				if !(initialCertificate.validityState == .valid || initialCertificate.validityState == .expiringSoon) {
					shouldShowCaption = true
				}
			}
			
			self.caption = shouldShowCaption ? Self.caption(for: initialCertificate) : nil
		}

		if let admissionState = healthCertifiedPerson.dccWalletInfo?.admissionState,
		   admissionState.visible, !(admissionState.badgeText?.localized(cclService: cclService) ?? "").isEmpty {
			isShortAdmissionStatusVisible = true
			shortAdmissionStatus = admissionState.badgeText?.localized(cclService: cclService)
		} else {
			isShortAdmissionStatusVisible = false
			shortAdmissionStatus = nil
		}
		
		if let maskState = healthCertifiedPerson.dccWalletInfo?.maskState,
		   maskState.visible, !(maskState.badgeText?.localized(cclService: cclService) ?? "").isEmpty {
			maskStatus = maskState.badgeText?.localized(cclService: cclService)
			isMaskStatusVisible = true
			maskStateIdentifier = maskState.identifier
		} else {
			maskStatus = nil
			isMaskStatusVisible = false
			maskStateIdentifier = .other
		}

		if let certificates = healthCertifiedPerson.dccWalletInfo?.verification.certificates.prefix(3), certificates.count == 2 || certificates.count == 3 {
			switchableHealthCertificates = certificates.reduce(into: OrderedDictionary<String, HealthCertificate>()) {
				if let certificate = healthCertifiedPerson.healthCertificate(for: $1.certificateRef) {
					$0[$1.buttonText.localized(cclService: cclService)] = certificate
				}
			}
		} else {
			switchableHealthCertificates = [:]
		}

		self.onTapToDelete = nil
		
		setupSubscriptions()
	}

	init?(
		decodingFailedHealthCertificate: DecodingFailedHealthCertificate,
		onCovPassCheckInfoButtonTap: @escaping () -> Void,
		onTapToDelete: @escaping (DecodingFailedHealthCertificate) -> Void
	) {
		backgroundGradientType = .solidGrey

		title = AppStrings.HealthCertificate.Overview.covidTitle
		name = ""

		qrCodeViewModel = HealthCertificateQRCodeViewModel(
			base45: decodingFailedHealthCertificate.base45,
			shouldBlockCertificateCode: false,
			imageAccessibilityTraits: .image,
			accessibilityLabel: AppStrings.HealthCertificate.Overview.covidDescription,
			qrCodeAccessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.qrCodeView(of: decodingFailedHealthCertificate.base45),
			covPassCheckInfoPosition: .bottom,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		self.caption = .validityState(
			image: UIImage(named: "Icon_ExpiredInvalid"),
			description: "\(String(describing: decodingFailedHealthCertificate.error))"
		)

		shortAdmissionStatus = nil
		maskStatus = nil
		maskStateIdentifier = .other
		
		isShortAdmissionStatusVisible = false
		isMaskStatusVisible = false

		switchableHealthCertificates = [:]

		self.onTapToDelete = {
			onTapToDelete(decodingFailedHealthCertificate)
		}
		
		setupSubscriptions()
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

	let shortAdmissionStatus: String?
	let maskStatus: String?
	let maskStateIdentifier: MaskStateIdentifier
	
	let isShortAdmissionStatusVisible: Bool
	let isMaskStatusVisible: Bool
	
	let switchableHealthCertificates: OrderedDictionary<String, HealthCertificate>

	let onTapToDelete: (() -> Void)?
	var onUpdateGradientType: ((GradientView.GradientType) -> Void)?

	var fontColorForMaskState: UIColor {
		switch maskStateIdentifier {
		case .maskRequired:
			return .enaColor(for: .maskBadgeGrey)
		case .maskOptional, .other:
			return .enaColor(for: .textContrast)
		}
	}
	
	var imageForMaskState: UIImage? {
		switch maskStateIdentifier {
		case .maskRequired:
			return UIImage(imageLiteralResourceName: "Icon_maskRequired")
		case .maskOptional, .other:
			return UIImage(imageLiteralResourceName: "Icon_maskOptional")
		}
	}

	var gradientForMaskState: GradientView.GradientType {
		switch maskStateIdentifier {
		case .maskRequired:
			return .whiteWithGreyBorder
		case .maskOptional, .other:
			return .solidLightGreen
		}
	}
	
	var gradientForAdmissionState: GradientView.GradientType {
		if maskStateIdentifier == .maskOptional {
			return .solidDarkGreen
		} else {
			return backgroundGradientType
		}
	}
	
	func showHealthCertificate(at index: Int) {
		qrCodeViewModel.updateImage(with: switchableHealthCertificates.elements[index].value)
	}

	// MARK: - Private
	
	private var healthCertifiedPerson: HealthCertifiedPerson?
	
	private var subscriptions: Set<AnyCancellable> = []

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
				format: AppStrings.HealthCertificate.ValidityState.expiringSoonLong,
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
		case .blocked, .revoked:
			return .validityState(
				image: UIImage(named: "Icon_ExpiredInvalid"),
				description: AppStrings.HealthCertificate.ValidityState.blockedRevoked
			)
		}
	}
	
	private func setupSubscriptions() {
		guard let healthCertifiedPerson = healthCertifiedPerson else { return }
		
		healthCertifiedPerson.$gradientType
			.sink { [weak self] in self?.onUpdateGradientType?($0) }
			.store(in: &subscriptions)
	}
}

extension HealthCertifiedPersonCellModel {
	enum MaskAndAdmissionStatesConfiguration {
		/// Show Nothing
		case maskStateInvisibleAdmissionStateInvisible
		
		/// Show Admission Status Badge alone on the right side
		case maskStateInvisibleAdmissionStateVisible
		
		/// Show only Mask Status Badge with 100% width
		case maskStateVisibleAdmissionStateInvisible
		
		/// Show Mask Status Badge and Admission Status Badge
		case maskStateVisibleAdmissionStateVisible
		
		/// Show Spacer with 100% width
		case maskStateInvisibleAdmissionStateNull
		
		/// Show Mask Status Badge with 80% width
		case maskStateVisibleAdmissionStateNull
		
		/// Show Spacer with 100% width
		case maskStateNullAdmissionStateNull
	}
	
	/// Returns how to configure the view for mask and admission states
	var maskAndAdmissionStatesConfiguration: MaskAndAdmissionStatesConfiguration {
		switch (healthCertifiedPerson?.dccWalletInfo?.maskState?.visible, healthCertifiedPerson?.dccWalletInfo?.admissionState.visible) {
		case (false, false):
			return .maskStateInvisibleAdmissionStateInvisible
		case (false, true):
			return .maskStateInvisibleAdmissionStateVisible
		case (true, true):
			return .maskStateVisibleAdmissionStateVisible
		case (false, nil):
			return .maskStateInvisibleAdmissionStateNull
		case (true, nil):
			return .maskStateVisibleAdmissionStateNull
		case (nil, nil):
			return .maskStateNullAdmissionStateNull
		default:
			return .maskStateInvisibleAdmissionStateInvisible
		}
	}
}
