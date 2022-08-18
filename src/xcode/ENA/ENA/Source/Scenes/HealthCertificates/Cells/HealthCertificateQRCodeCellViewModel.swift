////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIColor
import UIKit.UIImage

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		mode: Mode,
		healthCertificate: HealthCertificate,
		accessibilityText: String,
		onCovPassCheckInfoButtonTap: @escaping () -> Void
	) {
		self.mode = mode
		self.healthCertificate = healthCertificate

		self.qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			showRealQRCodeIfValidityStateBlocked: mode == .details,
			imageAccessibilityTraits: .image,
			accessibilityLabel: accessibilityText,
			qrCodeAccessibilityID: AccessibilityIdentifiers.HealthCertificate.qrCodeView(of: healthCertificate.uniqueCertificateIdentifier),
			covPassCheckInfoPosition: .top,
			onCovPassCheckInfoButtonTap: onCovPassCheckInfoButtonTap
		)

		if !healthCertificate.isConsideredValid {
			switch healthCertificate.validityState {
			case .valid:
				self.validityStateIcon = nil
				self.validityStateTitle = nil
				self.validityStateDescription = nil
				self.isUnseenNewsIndicatorVisible = false
			case .expiringSoon:
				self.validityStateIcon = UIImage(named: "Icon_ExpiringSoon")
				self.validityStateTitle = String(
					format: AppStrings.HealthCertificate.ValidityState.expiringSoonLong,
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .none, timeStyle: .short)
				)
				self.validityStateDescription = mode == .details ? AppStrings.HealthCertificate.ValidityState.expiringSoonDescription : nil
				self.isUnseenNewsIndicatorVisible = mode == .details && healthCertificate.isValidityStateNew
			case .expired:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.expired
				self.validityStateDescription = mode == .details ? AppStrings.HealthCertificate.ValidityState.expiredDescription : nil
				self.isUnseenNewsIndicatorVisible = mode == .details && healthCertificate.isValidityStateNew
			case .invalid:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.invalid
				self.validityStateDescription = mode == .details ? AppStrings.HealthCertificate.ValidityState.invalidDescription : nil
				self.isUnseenNewsIndicatorVisible = mode == .details && healthCertificate.isValidityStateNew
			case .blocked, .revoked:
				   self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				   self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.blockedRevoked
				   if mode == .details {
					   if healthCertificate.cborWebTokenHeader.issuer == "DE" {
						   self.validityStateDescription = AppStrings.HealthCertificate.ValidityState.blockedRevokedDescriptionDE
					   } else {
						   self.validityStateDescription = AppStrings.HealthCertificate.ValidityState.blockedRevokedDescriptionOther
					   }
				   } else {
					   self.validityStateDescription = nil
				   }
				   self.isUnseenNewsIndicatorVisible = mode == .details && healthCertificate.isValidityStateNew
		   }
		} else {
			self.validityStateIcon = nil
			self.validityStateTitle = nil
			self.validityStateDescription = nil
			self.isUnseenNewsIndicatorVisible = false
		}
	}

	// MARK: - Internal

	enum Mode {
		case overview
		case details
	}

	let qrCodeViewModel: HealthCertificateQRCodeViewModel

	var title: String? {
		if mode == .overview || !healthCertificate.isConsideredValid {
			switch healthCertificate.entry {
			case .vaccination:
				return AppStrings.HealthCertificate.Person.VaccinationCertificate.headline
			case .test:
				return AppStrings.HealthCertificate.Person.TestCertificate.headline
			case .recovery:
				return AppStrings.HealthCertificate.Person.RecoveryCertificate.headline
			}
		} else {
			return nil
		}
	}
	
	var titleAccessibilityText: String? {
		guard let title = title, let subtitle = subtitle else {
			return nil
		}
		return title + ", " + subtitle
	}

	var subtitle: String? {
		if mode == .overview && (healthCertificate.validityState == .valid || healthCertificate.validityState == .expiringSoon || (healthCertificate.type == .test && healthCertificate.validityState == .expired)) {
			switch healthCertificate.entry {
			case .vaccination(let vaccinationEntry):
				return vaccinationEntry.localVaccinationDate.map {
					String(
						format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationDate,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			case .test(let testEntry):
				return testEntry.sampleCollectionDate.map {
					String(
						format: AppStrings.HealthCertificate.Person.TestCertificate.sampleCollectionDate,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .short)
					)
				}
			case .recovery(let recoveryEntry):
				return recoveryEntry.localDateOfFirstPositiveNAAResult.map {
					String(
						format: AppStrings.HealthCertificate.Person.RecoveryCertificate.positiveTestFrom,
						DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
					)
				}
			}
		} else {
			return nil
		}
	}

	let validityStateIcon: UIImage?
	let validityStateTitle: String?
	let validityStateDescription: String?

	let isUnseenNewsIndicatorVisible: Bool

	// MARK: - Private

	private let mode: Mode
	private let healthCertificate: HealthCertificate

}
