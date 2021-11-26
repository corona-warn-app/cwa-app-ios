//
// 🦠 Corona-Warn-App
//

import Foundation

// The Access Token is a JWT token with the following payload (as JSON):
//
// | Attribute | Type | Description |
// |---|---|---|
// | `iss` | string | The URL of the service provider |
// | `iat` | int | The issued at timestamp in seconds |
// | `exp` | int | The expiration timestamp in seconds |
// | `sub` | string | The subject of the transaction |
// | `aud` | string | The URL of the validation service |
// | `jti` | string | The token identifier  |
// | `v` | string | A version information |
// | `t` | int | The type of the validation (0 = Structure, 1 = Cryptographic, 2 = Full) |
// | `vc` | object | A data structure representing the validation conditions (see below) |

struct TicketValidationAccessToken: Codable {
	let iss: String
	let iat: Int
	let exp: Int
	let sub: String
	let aud: String
	let jti: String
	let v: String
	let t: Int
	let vc: TicketValidationConditions
}
