//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class MockTicketValidation: TicketValidating {
	
	// MARK: - Internal

	var initializationResult: Result<Void, TicketValidationError>?
	var firstConsentResult: Result<Void, TicketValidationError>?
	var validationResult: Result<TicketValidationResult, TicketValidationError>?

	func initialize(
		with initializationData: TicketValidationInitializationData,
		completion: (Result<Void, TicketValidationError>) -> Void
	) {
		completion(initializationResult ?? .success(()))
	}

	func grantFirstConsent(
		completion: (Result<Void, TicketValidationError>) -> Void
	) {
		completion(firstConsentResult ?? .success(()))
	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {

	}

	func validate(
		completion: (Result<TicketValidationResult, TicketValidationError>) -> Void
	) {
		completion(validationResult ?? .success(.fake()))
	}

	func cancel() {

	}

}
