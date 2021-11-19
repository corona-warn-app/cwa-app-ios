//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationInitializationData: Codable {
	let `protocol`: String
	let protocolVersion: String
	let serviceIdentity: String
	let privacyUrl: String
	let token: String
	let consent: String
	let subject: String
	let serviceProvider: String
	
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
