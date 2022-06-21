//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCReissuanceSendModel: Encodable {
	
	// MARK: - Internal

	let action: String
	let certificates: [String]
}
