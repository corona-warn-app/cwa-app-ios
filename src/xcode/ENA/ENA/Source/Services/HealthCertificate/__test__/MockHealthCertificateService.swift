////
// 🦠 Corona-Warn-App
//

import OpenCombine
import HealthCertificateToolkit

class MockHealthCertificateService: HealthCertificateServiceProviding {

	// MARK: - Protocol HealthCertificateServiceProviding

	var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])

	func registerHealthCertificate(
		base45: Base45,
		completion: (Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError>) -> Void
	) {
		var healthCertificates = healthCertifiedPersons.value.first?.healthCertificates ?? []

		if let healthCertificate = try? HealthCertificate(base45: base45) {
			healthCertificates.append(healthCertificate)
		}

		completion(.success(HealthCertifiedPerson(healthCertificates: healthCertificates, proofCertificate: nil)))
	}

	func removeHealthCertificate(_ healthCertificate: HealthCertificate) {
		if let index = healthCertifiedPersons.value.first?.healthCertificates.firstIndex(of: healthCertificate) {
			healthCertifiedPersons.value.first?.healthCertificates.remove(at: index)
		}
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	) {
		completion(.success(()))
	}

}
