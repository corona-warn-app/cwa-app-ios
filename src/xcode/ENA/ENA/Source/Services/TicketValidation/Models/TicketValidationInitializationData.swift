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
}
