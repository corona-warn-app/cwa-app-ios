//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateService: HealthCertificateServiceProviding {

	// MARK: - Init

	init(
		store: HealthCertificateStoring
	) {
		#if DEBUG
		self.store = isUITesting ? MockTestStore() : store
		#else
		self.store = store
		#endif

		updatePublishersFromStore()

		healthCertifiedPersons
			.sink { [weak self] healthCertifiedPersons in
				self?.store.healthCertifiedPersons = healthCertifiedPersons
				self?.updateHealthCertifiedPersonSubscriptions(for: healthCertifiedPersons)
			}
			.store(in: &subscriptions)

		#if DEBUG
		if isUITesting {
			// check launch arguments ->
			if UserDefaults.standard.bool(forKey: UITestingLaunchArguments.healthCertificate.firstHealthCertificate.remove(prefix: "-")) {
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
			} else if UserDefaults.standard.bool(forKey: UITestingLaunchArguments.healthCertificate.firstAndSecondHealthCertificate.remove(prefix: "-")) {
				registerHealthCertificate(base45: HealthCertificate.firstBase45Mock)
				registerHealthCertificate(base45: HealthCertificate.lastBase45Mock)
			}
		}
		#endif
	}

	// MARK: - Internal

	private(set) var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])

	@discardableResult
	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
				return .failure(.noVaccinationEntry)
			}

			let healthCertifiedPerson = healthCertifiedPersons.value.first ?? HealthCertifiedPerson(healthCertificates: [])

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.vaccinationCertificates.first?.uniqueCertificateIdentifier == vaccinationCertificate.uniqueCertificateIdentifier })
			if isDuplicate {
				return .failure(.vaccinationCertificateAlreadyRegistered)
			}

			let hasDifferentName = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.name.standardizedName != healthCertificate.name.standardizedName })
			if hasDifferentName {
				return .failure(.nameMismatch)
			}

			let hasDifferentDateOfBirth = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.dateOfBirthDate != healthCertificate.dateOfBirthDate })
			if hasDifferentDateOfBirth {
				return .failure(.dateOfBirthMismatch)
			}

			healthCertifiedPerson.healthCertificates.append(healthCertificate)
			healthCertifiedPerson.healthCertificates.sort(by: <)

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				healthCertifiedPersons.value.append(healthCertifiedPerson)
			}

			return .success((healthCertifiedPerson))
		} catch let error as CertificateDecodingError {
			return .failure(.decodingError(error))
		} catch {
			return .failure(.other(error))
		}
	}

	func removeHealthCertificate(_ healthCertificate: HealthCertificate) {
		for healthCertifiedPerson in healthCertifiedPersons.value {
			if let index = healthCertifiedPerson.healthCertificates.firstIndex(of: healthCertificate) {
				healthCertifiedPerson.healthCertificates.remove(at: index)

				if healthCertifiedPerson.healthCertificates.isEmpty {
					healthCertifiedPersons.value.removeAll(where: { $0 == healthCertifiedPerson })
				}

				break
			}
		}
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons.value = store.healthCertifiedPersons
	}

	// MARK: - Private

	private var store: HealthCertificateStoring

	private var healthCertifiedPersonSubscriptions = Set<AnyCancellable>()
	private var subscriptions = Set<AnyCancellable>()

	private func updateHealthCertifiedPersonSubscriptions(for healthCertifiedPersons: [HealthCertifiedPerson]) {
		healthCertifiedPersonSubscriptions = []

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectDidChange
				.sink { [weak self] _ in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.healthCertifiedPersons.value = self.healthCertifiedPersons.value
				}
				.store(in: &healthCertifiedPersonSubscriptions)
		}
	}

}
