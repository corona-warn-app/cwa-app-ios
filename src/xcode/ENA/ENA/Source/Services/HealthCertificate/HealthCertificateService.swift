////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateService: HealthCertificateServiceProviding {

	// MARK: - Init

	init(
		store: HealthCertificateStoring
	) {
		self.store = store

		updatePublishersFromStore()
	}

	// MARK: - Internal

	private(set) var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([]) {
		didSet {
			store.healthCertifiedPersons = healthCertifiedPersons.value

			updateSubscriptions()
		}
	}

	func registerHealthCertificate(
		base45: Base45,
		completion: (Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError>) -> Void
	) {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: base45)", log: .api)

		do {
			let healthCertificate = try HealthCertificate(base45: base45)

			guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
				completion(.failure(.noVaccinationEntry))
				return
			}

			let healthCertifiedPerson = healthCertifiedPersons.value.first ?? HealthCertifiedPerson(healthCertificates: [], proofCertificate: nil)

			let isDuplicate = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.vaccinationCertificates.first?.uniqueCertificateIdentifier == vaccinationCertificate.uniqueCertificateIdentifier })
			if isDuplicate {
				completion(.failure(.vaccinationCertificateAlreadyRegistered))
				return
			}

			let hasDifferentName = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.name.standardizedName != healthCertificate.name.standardizedName })
			if hasDifferentName {
				completion(.failure(.nameMismatch))
				return
			}

			let hasDifferentDateOfBirth = healthCertifiedPerson.healthCertificates
				.contains(where: { $0.dateOfBirth != healthCertificate.dateOfBirth })
			if hasDifferentDateOfBirth {
				completion(.failure(.dateOfBirthMismatch))
				return
			}

			if !healthCertifiedPersons.value.contains(healthCertifiedPerson) {
				healthCertifiedPersons.value.append(healthCertifiedPerson)
			}

			completion(.success((healthCertifiedPerson)))
		} catch let error as CertificateDecodingError {
			completion(.failure(.decodingError(error)))
		} catch {
			// TODO!
//			completion(.failure(.decodingError(nil)))
		}
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	) {
		guard shouldAutomaticallyUpdateProofCertificate || trigger != .automatic else {
			Log.info("[HealthCertificateService] Not requesting proof for health certified person: \(private: healthCertifiedPerson). (proofCertificateUpdatePending: \(proofCertificateUpdatePending), lastProofCertificateUpdate: \(String(describing: lastProofCertificateUpdate)), trigger: \(trigger))", log: .api)

			return
		}

		Log.info("[HealthCertificateService] Requesting proof for health certified person: \(private: healthCertifiedPerson). (proofCertificateUpdatePending: \(proofCertificateUpdatePending), lastProofCertificateUpdate: \(String(describing: lastProofCertificateUpdate)), trigger: \(trigger)", log: .api)

		ProofCertificateAccess().fetchProofCertificate(
			for: healthCertifiedPerson.healthCertificates.map { $0.base45 },
			completion: { result in
				switch result {
				case .success(let cborData):
					do {
						healthCertifiedPerson.proofCertificate = try ProofCertificate(cborData: cborData)
						completion(.success(()))
					} catch let error as CertificateDecodingError {
						completion(.failure(.decodingError(error)))
					} catch {
						// TODO!
//						completion(.failure(.decodingError(nil)))
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

	// LAST_SUCCESSFUL_PC_RUN_TIMESTAMP
	private var lastProofCertificateUpdate: Date? {
		get { store.lastProofCertificateUpdate }
		set { store.lastProofCertificateUpdate = newValue }
	}

	// PC_RUN_PENDING
	private var proofCertificateUpdatePending: Bool {
		get { store.proofCertificateUpdatePending }
		set { store.proofCertificateUpdatePending = newValue }
	}

	private var shouldAutomaticallyUpdateProofCertificate: Bool {
		if proofCertificateUpdatePending {
			return true
		}

		guard let lastProofCertificateUpdate = lastProofCertificateUpdate else {
			return true
		}

		return !Calendar.utc().isDateInToday(lastProofCertificateUpdate)
	}

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
