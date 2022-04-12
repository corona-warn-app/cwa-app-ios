//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCReissuanceSendModel: Encodable {
	
	// MARK: - Internal

	let action: String = "renew"
	let certificates: [String]
}
