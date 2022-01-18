//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

#if DEBUG

struct MockHealthCertificateValidationService: HealthCertificateValidationProviding {

	// MARK: - Protocol HealthCertificateValidationProviding
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		completion(validationResult)
	}

	// MARK: - Internal

	var validationResult: Result<HealthCertificateValidationReport, HealthCertificateValidationError> = .success(.validationPassed([]))

}

#endif
