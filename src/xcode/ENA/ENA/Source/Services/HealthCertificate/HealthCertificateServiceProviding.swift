////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol HealthCertificateServiceProviding {

	var healthCertifiedPersons: CurrentValueSubject<[HealthCertifiedPerson], Never> { get }

	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError>

	func removeHealthCertificate(_ healthCertificate: HealthCertificate)

	func updateProofCertificate(
		for healthCertifiedPerson: HealthCertifiedPerson,
		trigger: FetchProofCertificateTrigger,
		completion: @escaping (Result<Void, HealthCertificateServiceError.ProofRequestError>) -> Void
	)

}
