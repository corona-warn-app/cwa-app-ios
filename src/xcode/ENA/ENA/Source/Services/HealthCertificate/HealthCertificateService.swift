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
		self.store = store

		updatePublishersFromStore()

		NotificationCenter.default.ocombine
			.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.healthCertifiedPersons.value.forEach { healthCertifiedPerson in
					self?.updateProofCertificate(
						for: healthCertifiedPerson,
						trigger: .automatic,
						completion: { _ in }
					)
				}
			}
			.store(in: &subscriptions)

	}

	// MARK: - Internal

	private(set) var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([]) {
		didSet {
			store.healthCertifiedPersons = healthCertifiedPersons.value

			updateSubscriptions()
		}
	}

	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError> {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
				return .failure(.noVaccinationEntry)
			}

			let healthCertifiedPerson = healthCertifiedPersons.value.first ?? HealthCertifiedPerson(healthCertificates: [], proofCertificate: nil)

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
				.contains(where: { $0.dateOfBirth != healthCertificate.dateOfBirth })
			if hasDifferentDateOfBirth {
				return .failure(.dateOfBirthMismatch)
			}

			healthCertifiedPerson.healthCertificates.append(healthCertificate)

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				healthCertifiedPersons.value.append(healthCertifiedPerson)
			}

			if healthCertificate.isEligibleForProofCertificate {
				healthCertifiedPerson.proofCertificateUpdatePending = true
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
				} else if healthCertificate.isEligibleForProofCertificate {
					healthCertifiedPerson.proofCertificateUpdatePending = true
				}

				break
			}
		}
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: @escaping (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	) {
		guard healthCertifiedPerson.shouldAutomaticallyUpdateProofCertificate || trigger != .automatic else {
			Log.info("[HealthCertificateService] Not requesting proof for health certified person: \(private: healthCertifiedPerson). (proofCertificateUpdatePending: \(healthCertifiedPerson.proofCertificateUpdatePending), lastProofCertificateUpdate: \(String(describing: healthCertifiedPerson.lastProofCertificateUpdate)), trigger: \(trigger))", log: .api)

			return
		}

		Log.info("[HealthCertificateService] Requesting proof for health certified person: \(private: healthCertifiedPerson). (proofCertificateUpdatePending: \(healthCertifiedPerson.proofCertificateUpdatePending), lastProofCertificateUpdate: \(String(describing: healthCertifiedPerson.lastProofCertificateUpdate)), trigger: \(trigger)", log: .api)

		let healthCertificates = healthCertifiedPerson.healthCertificates
			.filter { $0.isEligibleForProofCertificate }
			.map { $0.base45 }

		if healthCertificates.isEmpty {
			healthCertifiedPerson.removeProofCertificateIfExpired()
			completion(.success(()))
		}

		ProofCertificateAccess().fetchProofCertificate(
			for: healthCertificates,
			completion: { result in
				switch result {
				case .success(let cborData):
					do {
						healthCertifiedPerson.lastProofCertificateUpdate = Date()
						healthCertifiedPerson.proofCertificateUpdatePending = false

						healthCertifiedPerson.removeProofCertificateIfExpired()

						if let cborData = cborData {
							healthCertifiedPerson.proofCertificate = try ProofCertificate(cborData: cborData)
						}

						completion(.success(()))
					} catch let error as CertificateDecodingError {
						completion(.failure(.decodingError(error)))
					} catch {
						completion(.failure(.other(error)))
					}
				case .failure(let error):
					completion(.failure(.fetchingError(error)))
				}
			}
		)
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons.value = store.healthCertifiedPersons
	}

	// MARK: - Private

	private var store: HealthCertificateStoring
	private var subscriptions = Set<AnyCancellable>()

	private func updateSubscriptions() {
		subscriptions = []

		healthCertifiedPersons.value.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectWillChange
				.receive(on: DispatchQueue.main.ocombine)
				.sink { [weak self] in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.healthCertifiedPersons.value = self.healthCertifiedPersons.value
				}
				.store(in: &subscriptions)
		}
	}

}
