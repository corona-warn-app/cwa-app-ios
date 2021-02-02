////
// 🦠 Corona-Warn-App
//

import Foundation

typealias OTPResponseProperties = Properties

// Needed to decode the server response
struct Properties: Codable {
	let expirationDate: Date?
	let errorCode: OTPServerErrorCode?
}
