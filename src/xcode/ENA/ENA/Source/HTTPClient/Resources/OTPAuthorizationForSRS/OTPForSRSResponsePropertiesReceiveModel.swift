//
// 🦠 Corona-Warn-App
//

import Foundation

struct OTPForSRSResponsePropertiesReceiveModel: Codable {
	let expirationDate: String?
	let errorCode: PPAServerErrorCode?
}
