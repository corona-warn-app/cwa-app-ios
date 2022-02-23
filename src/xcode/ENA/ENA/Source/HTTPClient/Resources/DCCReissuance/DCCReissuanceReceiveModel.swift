//
// 🦠 Corona-Warn-App
//

import Foundation

typealias DCCReissuanceReceiveModel = [DCCReissuanceCertificate]

struct DCCReissuanceCertificate: Codable {

	let certificate: String
	let relations: [DCCReissuanceRelation]
}

struct DCCReissuanceRelation: Codable {

	let index: Int
	let action: String
}
