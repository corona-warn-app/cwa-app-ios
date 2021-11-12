//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol TicketValidating {

	func initialize(
		with initializationData: TicketValidationInitializationData,
		completion: (Result<Void, TicketValidationError>) -> Void
	)

	func grantFirstConsent(
		completion: (Result<Void, TicketValidationError>) -> Void
	)

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	)

	func validate(
		completion: (Result<TicketValidationResult, TicketValidationError>) -> Void
	)

	func cancel()

}
