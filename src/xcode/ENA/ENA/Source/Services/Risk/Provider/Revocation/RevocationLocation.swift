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
	var certificates: [RevocationCoordinate: [HealthCertificate]]

}


struct RevocationCoordinate: Hashable {

	// MARK: - Init

	init(
		x: String,
		y: String
	) {
		self.x = x
		self.y = y
	}

	init(hash: String) {
		let data = Data(hex: hash)
		let first = Data(bytes: [data[0]], count: 1)
		let second = Data(bytes: [data[1]], count: 1)
		self.x = first.toHexString()
		self.y = second.toHexString()
	}

	// MARK: - Internal

	let x: String
	let y: String

}
