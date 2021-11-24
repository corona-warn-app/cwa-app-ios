//
// 🦠 Corona-Warn-App
//

import Foundation

final class MockTicketValidation: TicketValidating {

	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData
	) {
		self.initializationData = initializationData
	}

	var initializationData: TicketValidationInitializationData

	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.initializationResult ?? .success(()))
		}
	}

	func grantFirstConsent(
		completion: @escaping (Result<ValidationConditions, TicketValidationError>) -> Void
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
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.validationResult ?? .success(.fake()))
		}
	}

	func cancel() {

	}

	// MARK: - Internal

	var initializationResult: Result<Void, TicketValidationError>?
	var firstConsentResult: Result<ValidationConditions, TicketValidationError>?
	var validationResult: Result<TicketValidationResult, TicketValidationError>?

	var delay: TimeInterval = 0

}
