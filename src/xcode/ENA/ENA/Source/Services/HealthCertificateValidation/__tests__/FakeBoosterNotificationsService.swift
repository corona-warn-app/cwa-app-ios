//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import HealthCertificateToolkit

import class CertLogic.ValidationResult

struct FakeBoosterNotificationsService: BoosterNotificationsServiceProviding {

	// MARK: - Protocol BoosterNotificationsServiceProviding
	
	func applyRulesForCertificates(
		certificates: [DigitalCovidCertificateWithHeader],
		completion: @escaping (Result<ValidationResult, BoosterNotificationServiceError>) -> Void
	) {
		completion(result ?? .failure(.BOOSTER_VALIDATION_ERROR(.NO_PASSED_RESULT)))
	}
	
	// MARK: - Internal
	
	var result: Result<ValidationResult, BoosterNotificationServiceError>?

}
