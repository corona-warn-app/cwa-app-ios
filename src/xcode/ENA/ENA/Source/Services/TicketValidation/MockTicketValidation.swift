//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class MockTicketValidation: TicketValidating {

	// MARK: - Protocol TicketValidating

	var serviceProvider: String {
		initializationData?.serviceProvider ?? ""
	}

	var subject: String {
		initializationData?.subject ?? ""
	}

	func initialize(
		with initializationData: TicketValidationInitializationData,
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.initializationResult ?? .success(()))
		}
	}

	func grantFirstConsent(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {
		DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
			completion(self.firstConsentResult ?? .success(()))
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
	var firstConsentResult: Result<Void, TicketValidationError>?
	var validationResult: Result<TicketValidationResult, TicketValidationError>?

	var delay: TimeInterval = 0

	// MARK: - Private

	private var initializationData: TicketValidationInitializationData?

}
