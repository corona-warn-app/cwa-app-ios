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
		completion: (Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError>) -> Void
	)

	func removeHealthCertificate(_ healthCertificate: HealthCertificate)

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	)

}
