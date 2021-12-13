//
// 🦠 Corona-Warn-App
//

import Foundation

protocol TicketValidating {

	var initializationData: TicketValidationInitializationData { get }
	var allowList: TicketValidationAllowList { get }
	
	func initialize(
		appFeatureProvider: AppFeatureProviding,
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	)

	func grantFirstConsent(
		completion: @escaping (Result<TicketValidationConditions, TicketValidationError>) -> Void
	)

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	)

	func validate(
		completion: @escaping (Result<TicketValidationResultToken, TicketValidationError>) -> Void
	)

	func cancel()

}
