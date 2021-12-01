//
// 🦠 Corona-Warn-App
//

import Foundation

#if DEBUG

final class MockTicketValidation: TicketValidating {

	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData
	) {
		self.initializationData = initializationData
	}

	let initializationData: TicketValidationInitializationData

	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.initializationResult ?? .success(()))
		}
	}

	func grantFirstConsent(
		completion: @escaping (Result<TicketValidationConditions, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.firstConsentResult ?? .success(.fake()))
		}
	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {

	}

	func validate(
		completion: @escaping (Result<TicketValidationResultToken, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.validationResult ?? .success(.fake()))
		}
	}

	func cancel() {

	}

	// MARK: - Internal

	var initializationResult: Result<Void, TicketValidationError>?
	var firstConsentResult: Result<TicketValidationConditions, TicketValidationError>?
	var validationResult: Result<TicketValidationResultToken, TicketValidationError>?

	var delay: TimeInterval = 0
	
}

#endif
