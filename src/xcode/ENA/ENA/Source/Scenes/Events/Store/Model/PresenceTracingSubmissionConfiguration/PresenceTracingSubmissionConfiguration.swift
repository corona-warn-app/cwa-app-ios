//
// 🦠 Corona-Warn-App
//

import Foundation

struct PresenceTracingSubmissionConfiguration: Codable {

	// MARK: - Init

	init(from presenceTracingSubmissionParameters: SAP_Internal_V2_PresenceTracingSubmissionParameters) {
		self.durationFilters = presenceTracingSubmissionParameters.durationFilters.map { DurationFilter(from: $0) }
		self.aerosoleDecayLinearFunctions = presenceTracingSubmissionParameters.aerosoleDecayLinearFunctions.map { AerosoleDecayFunctionLinear(from: $0) }
	}

	// MARK: - Internal

	let durationFilters: [DurationFilter]
	let aerosoleDecayLinearFunctions: [AerosoleDecayFunctionLinear]
	
}
