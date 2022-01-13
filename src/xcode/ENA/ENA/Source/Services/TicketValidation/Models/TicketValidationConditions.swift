//
// 🦠 Corona-Warn-App
//

import Foundation

// The Validation Conditions are a JSON object with the following attributes. Note that _all_ attributes are optional.
//
// | Attribute | Type | Description |
// |---|---|---|
// | `hash` | string<br />(optional) | Hash of the DCC |
// | `lang` | string<br />(optional) | Selected language |
// | `fnt` | string<br />(optional) | Transliterated family name |
// | `gnt` | string<br />(optional) | Transliterated given name |
// | `dob` | string<br />(optional) | Date of birth |
// | `type` | string[]<br />(optional) | The acceptable type of DCC |
// | `coa` | string<br />(optional) | Country of arrival |
// | `roa` | string<br />(optional) | Region of arrival |
// | `cod` | string<br />(optional) | Country of departure |
// | `rod` | string<br />(optional) | Region of departure |
// | `category` | string[]<br />(optional) | Category for validation |
// | `validationClock` | string<br />(optional) | ISO8601 date where the DCC must be validatable |
// | `validFrom` | string<br />(optional) | ISO8601 date where the DCC must be valid from |
// | `validTo` | string<br />(optional) | ISO8601 date where the DCC must be valid to |

struct TicketValidationConditions: Equatable, Codable {
	let hash: String?
	let lang: String?
	let fnt: String?
	let gnt: String?
	let dob: String?
	let type: [String]?
	let coa: String?
	let roa: String?
	let cod: String?
	let rod: String?
	let category: [String]?
	let validationClock: String?
	let validFrom: String?
	let validTo: String?
}
