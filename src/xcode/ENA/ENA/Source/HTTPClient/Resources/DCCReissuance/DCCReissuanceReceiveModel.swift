//
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCReissuanceReceiveModel: Codable {

	let certificates: [DCCReissuanceCertificates]
}

struct DCCReissuanceCertificates: Codable {

	let certificate: String
	let relations: [DCCReissuanceRelations]
}

struct DCCReissuanceRelations: Codable {

	let index: Int
	let action: String
}
