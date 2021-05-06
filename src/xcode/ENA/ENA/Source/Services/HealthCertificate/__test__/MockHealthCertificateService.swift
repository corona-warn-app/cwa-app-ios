////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

class MockHealthCertificateService: HealthCertificateServiceProviding {

	var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])

	func registerHealthCertificate(
		base45: Base45,
		completion: (Result<HealthCertifiedPerson, HealthCertificateService.RegistrationError>) -> Void
	) {
		let healthCertificate = try? HealthCertificate(base45: base45)
		completion(.success(HealthCertifiedPerson(healthCertificates: [healthCertificate].compactMap { $0 }, proofCertificate: nil)))
	}

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateService.ProofRequestError>) -> Void
	) {
		completion(.success(()))
	}

}
