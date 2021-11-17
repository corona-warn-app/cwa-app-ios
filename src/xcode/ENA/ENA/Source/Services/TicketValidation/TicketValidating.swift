//
// 🦠 Corona-Warn-App
//

import Foundation

protocol TicketValidating {

	init(
		with initializationData: TicketValidationInitializationData
	)

	var initializationData: TicketValidationInitializationData { get }

	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	)

	func grantFirstConsent(
		completion: @escaping (Result<ValidationConditions, TicketValidationError>) -> Void
	)

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	)

	func validate(
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
	)

	func cancel()

}
