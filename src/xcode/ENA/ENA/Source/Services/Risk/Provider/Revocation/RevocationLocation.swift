//
// 🦠 Corona-Warn-App
//

import Foundation

struct RevocationLocation: Hashable {

	// MARK: Protocol - Hashable

	func hash(into hasher: inout Hasher) {
		hasher.combine(keyIdentifier)
		hasher.combine(type)
	}

	// MARK: Internal

	let keyIdentifier: String
	let type: String
	var certificates: [Coordinate: [HealthCertificate]]

	struct Coordinate: Hashable {
		let x: String
		let y: String
	}

}
