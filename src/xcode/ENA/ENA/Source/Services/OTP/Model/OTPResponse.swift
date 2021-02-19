////
// 🦠 Corona-Warn-App
//

import Foundation

// Do not edit this struct as it has the properties as we get them from the server response.
struct OTPResponseProperties: Codable {
	let expirationDate: Date?
	let errorCode: PPAServerErrorCode?
}
