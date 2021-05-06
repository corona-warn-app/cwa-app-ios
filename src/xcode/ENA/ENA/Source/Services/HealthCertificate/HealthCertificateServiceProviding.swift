////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol HealthCertificateServiceProviding {

	var healthCertifiedPersons: CurrentValueSubject<[HealthCertifiedPerson], Never> { get }

	func registerHealthCertificate(
		base45: Base45,
		completion: (Result<HealthCertifiedPerson, HealthCertificateService.RegistrationError>) -> Void
	)

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateService.ProofRequestError>) -> Void
	)

}
