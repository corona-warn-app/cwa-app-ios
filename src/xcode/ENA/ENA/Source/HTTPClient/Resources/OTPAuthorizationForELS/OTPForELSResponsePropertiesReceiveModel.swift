//
// 🦠 Corona-Warn-App
//

import Foundation

struct OTPForELSResponsePropertiesReceiveModel: Codable {
	let expirationDate: Date?
	let errorCode: PPAServerErrorCode?
}
