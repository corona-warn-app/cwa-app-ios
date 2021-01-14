//
// 🦠 Corona-Warn-App
//

import Foundation

struct MinutesAtAttenuationFilter: Codable {

	// MARK: - Init

	init(from minutesAtAttenuationFilter: SAP_Internal_V2_MinutesAtAttenuationFilter) {
		self.attenuationRange = ENARange(from: minutesAtAttenuationFilter.attenuationRange)
		self.dropIfMinutesInRange = ENARange(from: minutesAtAttenuationFilter.dropIfMinutesInRange)
	}

	// MARK: - Internal

	let attenuationRange: ENARange
	let dropIfMinutesInRange: ENARange

}
