//
// 🦠 Corona-Warn-App
//

import Foundation

// The Result Token is a JWT token with the following payload (as JSON):
//
// | Attribute | Type | Description |
// |---|---|---|
// | `iss` | string | The URL of the issuer |
// | `iat` | int | The issued at timestamp in seconds |
// | `exp` | int | The expiration timestamp in seconds |
// | `sub` | string | The subject of the transaction |
// | `category` | string[] | The categories of confirmation |
// | `result` | string | The result of the validation (`OK` for pass, `CHK` for open, `NOK` for fail) |
// | `results` | object[] | An array of Result Item objects (see below) |
// | `confirmation` | string | A JWT token with reduced set of information about the result. |

struct TicketValidationResult {

	let iss: String
	let iat: Int
	let exp: Int
	let sub: String
	let category: String
	let result: Result
	let results: [ResultItem]
	let confirmation: String

	// A Result Item is a JSON object with the following attributes.
	//
	// | Attribute | Type | Description |
	// |---|---|---|
	// | `identifier` | string | Identifier of the check |
	// | `result` | string | The result of the validation (`OK` for pass, `CHK` for open, `NOK` for fail) |
	// | `type` | string | The type of check |
	// | `details` | string | Description of the check |
	
	struct ResultItem {
		let identifier: String
		let result: Result
		let type: String
		let details: String
	}

	enum Result: String {
		case passed = "OK"
		case open = "CHK"
		case failed = "NOK"
	}

}
