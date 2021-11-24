//
// 🦠 Corona-Warn-App
//

import Foundation

struct TicketValidationResult {

	let iss: String
	let iat: Int
	let exp: Int
	let sub: String
	let category: String
	let result: Result
	let results: [ResultItem]
	let confirmation: String

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
