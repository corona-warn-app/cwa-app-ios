////
// 🦠 Corona-Warn-App
//

import Foundation

struct OTPToken: Codable {
	let token: String
	let timestamp: Date
	let expirationDate: Date?
	let authorizationDate: Date?
}
