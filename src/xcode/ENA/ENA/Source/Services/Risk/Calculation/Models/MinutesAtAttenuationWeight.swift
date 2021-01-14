//
// 🦠 Corona-Warn-App
//

import Foundation

struct MinutesAtAttenuationWeight: Codable {

	// MARK: - Init

	init(from minutesAtAttenuationWeight: SAP_Internal_V2_MinutesAtAttenuationWeight) {
		self.attenuationRange = ENARange(from: minutesAtAttenuationWeight.attenuationRange)
		self.weight = minutesAtAttenuationWeight.weight
	}

	// MARK: - Internal

	let attenuationRange: ENARange
	let weight: Double
	
}
