//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TicketValidation: TicketValidating {
	
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
		self.initializationData = initializationData


	}

	func grantFirstConsent(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {

	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {

	}

	func validate(
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
	) {

	}

	func cancel() {

	}

	// MARK: - Private

	private var initializationData: TicketValidationInitializationData?

}
