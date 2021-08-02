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
		onValidationButtonTap: ((HealthCertificate, @escaping (Bool) -> Void) -> Void)? = nil
	) {
		self.mode = mode
		self.healthCertificate = healthCertificate
		self.onValidationButtonTap = onValidationButtonTap

		self.qrCodeViewModel = HealthCertificateQRCodeViewModel(
			healthCertificate: healthCertificate,
			accessibilityLabel: accessibilityText
		)

		if healthCertificate.validityState == .invalid ||
			(healthCertificate.type != .test && healthCertificate.validityState != .valid) {
			switch healthCertificate.validityState {
			case .valid:
				self.validityStateIcon = nil
				self.validityStateTitle = nil
				self.validityStateDescription = nil
			case .expiringSoon:
				self.validityStateIcon = UIImage(named: "Icon_ExpiringSoon")
				self.validityStateTitle = String(
					format: AppStrings.HealthCertificate.ValidityState.expiringSoon,
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .short, timeStyle: .none),
					DateFormatter.localizedString(from: healthCertificate.expirationDate, dateStyle: .none, timeStyle: .short)
				)
				if mode == .details {
					self.validityStateDescription = AppStrings.HealthCertificate.ValidityState.expiringSoonDescription
				} else {
					self.validityStateDescription = nil
				}
			case .expired:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.expired
				if mode == .details {
					self.validityStateDescription = AppStrings.HealthCertificate.ValidityState.expiredDescription
				} else {
					self.validityStateDescription = nil
				}
			case .invalid:
				self.validityStateIcon = UIImage(named: "Icon_ExpiredInvalid")
				self.validityStateTitle = AppStrings.HealthCertificate.ValidityState.invalid
				if mode == .details {
					self.validityStateDescription = AppStrings.HealthCertificate.ValidityState.invalidDescription
				} else {
					self.validityStateDescription = nil
				}
			}
		} else {
			self.validityStateIcon = nil
			self.validityStateTitle = nil
			self.validityStateDescription = nil
		}
	}

	// MARK: - Internal

	enum Mode {
		case overview
		case details
	}

	let backgroundColor: UIColor = .enaColor(for: .cellBackground2)
	let borderColor: UIColor = .enaColor(for: .hairline)

	let qrCodeViewModel: HealthCertificateQRCodeViewModel

	var title: String? {
		if mode == .overview ||
			healthCertificate.validityState == .invalid ||
			(healthCertificate.type != .test && healthCertificate.validityState != .valid) {
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

	var subtitle: String? {
		if mode == .overview && (healthCertificate.validityState == .valid || healthCertificate.validityState == .expiringSoon) {
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
				return recoveryEntry.localCertificateValidityEndDate.map {
					String(
						format: AppStrings.HealthCertificate.Person.RecoveryCertificate.validityDate,
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

	var isValidationButtonVisible: Bool {
		onValidationButtonTap != nil
	}

	func didTapValidationButton(loadingStateHandler: @escaping (Bool) -> Void) {
		onValidationButtonTap?(healthCertificate) { isLoading in
			loadingStateHandler(isLoading)
		}
	}

	// MARK: - Private

	private let mode: Mode
	private let healthCertificate: HealthCertificate
	private let onValidationButtonTap: ((HealthCertificate, @escaping (Bool) -> Void) -> Void)?

}
