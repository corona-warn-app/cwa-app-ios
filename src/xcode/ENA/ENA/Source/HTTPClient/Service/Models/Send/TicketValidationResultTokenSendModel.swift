//
// 🦠 Corona-Warn-App
//

struct TicketValidationResultTokenSendModel: Encodable {

	let kid: String
	let dcc: String
	let sig: String
	let encKey: String
	let encScheme: String
	let sigAlg: String

}
