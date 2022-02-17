//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCReissuanceReceiveModel: Codable {

	// MARK: - Internal

	let certificate: String
	let relations: [DCCReissuanceRelations]
}

struct DCCReissuanceRelations: Codable {

	let index: Int
	let action: String
}
