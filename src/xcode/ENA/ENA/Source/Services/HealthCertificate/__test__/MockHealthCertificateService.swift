////
// 🦠 Corona-Warn-App
//

import OpenCombine
import HealthCertificateToolkit
@testable import ENA

class MockHealthCertificateService: HealthCertificateServiceProviding {

	// MARK: - Protocol HealthCertificateServiceProviding

	var healthCertifiedPersons = CurrentValueSubject<[HealthCertifiedPerson], Never>([])

	func registerHealthCertificate(
		base45: Base45
	) -> Result<HealthCertifiedPerson, HealthCertificateServiceError.RegistrationError> {
		var healthCertificates = healthCertifiedPersons.value.first?.healthCertificates ?? []

		if let healthCertificate = try? HealthCertificate(base45: base45) {
			healthCertificates.append(healthCertificate)
		}

		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: healthCertificates)
		healthCertifiedPersons.value = [healthCertifiedPerson]
		return .success(healthCertifiedPerson)
	}

	func removeHealthCertificate(_ healthCertificate: HealthCertificate) {
		if let index = healthCertifiedPersons.value.first?.healthCertificates.firstIndex(of: healthCertificate) {
			healthCertifiedPersons.value.first?.healthCertificates.remove(at: index)
		}
	}

}
