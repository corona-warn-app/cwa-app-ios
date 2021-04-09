//
// 🦠 Corona-Warn-App
//

import Foundation

struct DurationFilter: Codable {

	// MARK: - Init

	init(from durationFilter: SAP_Internal_V2_PresenceTracingSubmissionParameters.DurationFilter) {
		self.dropIfMinutesInRange = ENARange(from: durationFilter.dropIfMinutesInRange)
	}

	// MARK: - Internal

	let dropIfMinutesInRange: ENARange

}
