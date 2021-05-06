////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring,
		healthCertificateToolkit: HealthCertificateToolkit = HealthCertificateToolkit()
	) {
		self.store = store
		self.healthCertificateToolkit = healthCertificateToolkit

		updatePublishersFromStore()
	}

	// MARK: - Internal

	@OpenCombine.Published private(set) var healthCertifiedPersons: [HealthCertifiedPerson] = [] {
		didSet {
			store.healthCertifiedPersons = healthCertifiedPersons

			updateSubscriptions()
		}
	}

	func register(
		payload: String,
		completion: (Result<HealthCertifiedPerson, RegistrationError>) -> Void
	) {
		Log.info("[HealthCertificateService] Registering health certificate from payload: \(private: payload)", log: .api)

		switch healthCertificateToolkit.decodeHealthCertificate(base45: payload) {
		case .success(let certificateRepresentations):
			do {
				let healthCertificate = try HealthCertificate(representations: certificateRepresentations)

				guard let vaccinationCertificate = healthCertificate.vaccinationCertificates.first else {
					completion(.failure(.noVaccinationEntry))
					return
				}

				let healthCertifiedPerson = healthCertifiedPersons.first ?? HealthCertifiedPerson(healthCertificates: [], proofCertificate: nil)

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

				if !healthCertifiedPersons.contains(healthCertifiedPerson) {
					healthCertifiedPersons.append(healthCertifiedPerson)
				}

				completion(.success((healthCertifiedPerson)))
			} catch {
				completion(.failure(.jsonDecodingError(error)))
			}
		case .failure(let error):
			completion(.failure(.decodingError(error)))
		}
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		completion: (Result<Void, ProofRequestError>) -> Void
	) {
		Log.info("[HealthCertificateService] Requesting proof for health certified person: \(private: healthCertifiedPerson)", log: .api)

		healthCertificateToolkit.fetchProofCertificate(
			for: healthCertifiedPerson.healthCertificates.map { $0.representations },
			completion: { result in
				switch result {
				case .success(let proofCertificateRepresentations):
					do {
						healthCertifiedPerson.proofCertificate = try ProofCertificate(representations: proofCertificateRepresentations)
						completion(.success(()))
					} catch {
						completion(.failure(.jsonDecodingError(error)))
					}
				case .failure(let error):
					completion(.failure(.fetchingError(error)))
				}
			}
		)
	}

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons = store.healthCertifiedPersons
	}

	// MARK: - Private

	private var store: HealthCertificateStoring
	private var healthCertificateToolkit: HealthCertificateToolkit
	private var subscriptions = Set<AnyCancellable>()

	private func updateSubscriptions() {
		subscriptions = []

		healthCertifiedPersons.forEach { healthCertifiedPerson in
			healthCertifiedPerson.objectWillChange
				.receive(on: DispatchQueue.main.ocombine)
				.sink { [weak self] in
					guard let self = self else { return }
					// Trigger publisher to inform subscribers and update store
					self.healthCertifiedPersons = self.healthCertifiedPersons
				}
				.store(in: &subscriptions)
		}
	}

}
