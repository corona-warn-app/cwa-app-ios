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
		let healthCertificate = try? HealthCertificate(base45: base45)
		completion(.success(HealthCertifiedPerson(healthCertificates: [healthCertificate].compactMap { $0 }, proofCertificate: nil)))
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	) {
		completion(.success(()))
	}

}
