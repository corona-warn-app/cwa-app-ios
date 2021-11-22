//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

extension TicketValidationInitializationData {
	static func fake (
		`protocol`: String = "protocol",
		protocolVersion: String = "protocolVersion",
		serviceIdentity: String = "serviceIdentity",
		privacyUrl: String = "privacyUrl",
		token: String = "token",
		consent: String = "consent",
		subject: String = "subject",
		serviceProvider: String = "serviceProvider"
	) -> TicketValidationInitializationData {
		return TicketValidationInitializationData(
			protocol: `protocol`,
			protocolVersion: protocolVersion,
			serviceIdentity: serviceIdentity,
			privacyUrl: privacyUrl,
			token: token,
			consent: consent,
			subject: subject,
			serviceProvider: serviceProvider
		)
	}
}
