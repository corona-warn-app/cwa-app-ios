//
// 🦠 Corona-Warn-App
//

import Foundation

struct OTPResponsePropertiesReceiveModel: Codable {
	let expirationDate: Date?
	let errorCode: PPAServerErrorCode?
}
