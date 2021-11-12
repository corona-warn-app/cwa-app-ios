//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class TicketValidation: TicketValidating {
	
	// MARK: - Internal

	func initialize(
		with initializationData: TicketValidationInitializationData,
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {

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

}
