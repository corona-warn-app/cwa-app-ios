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

	func registerTestCertificateRequest(
		coronaTestType: CoronaTestType,
		registrationToken: String,
		registrationDate: Date
	)

	func executeTestCertificateRequest(_ testCertificateRequest: TestCertificateRequest) throws

	func updatePublishersFromStore()

}
