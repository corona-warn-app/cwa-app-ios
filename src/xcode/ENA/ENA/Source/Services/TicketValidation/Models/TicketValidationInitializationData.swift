//
// 🦠 Corona-Warn-App
//

import Foundation

// The Initialization Data is a JSON object with the following attributes:
//
// | Attribute | Type | Description |
// |---|---|---|
// | `protocol` | string | Description of the protocol, typically `DCCVALIDATION`. |
// | `protocolVersion` | string | Protocol version according to Semantic Versioning. |
// | `serviceIdentity` | string | A URL to the Service Identity Document. |
// | `privacyUrl` | string | A URL for additional privacy information. |
// | `token` | string | A JWT token that can be used as credential to call the Access Token Service. |
// | `consent` | string | Consent text for display on the UI. |
// | `subject` | string | Identifier of the transaction. |
// | `serviceProvider` | string | Description of the Service Provider. |
										
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
