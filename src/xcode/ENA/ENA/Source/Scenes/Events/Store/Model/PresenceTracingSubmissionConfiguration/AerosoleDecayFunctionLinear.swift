//
// 🦠 Corona-Warn-App
//

import Foundation

struct AerosoleDecayFunctionLinear: Codable {

	// MARK: - Init

	init(from aerosoleDecayFunctionLinear: SAP_Internal_V2_PresenceTracingSubmissionParameters.AerosoleDecayFunctionLinear) {
		self.minutesRange = ENARange(from: aerosoleDecayFunctionLinear.minutesRange)
		self.slope = aerosoleDecayFunctionLinear.slope
		self.intercept = aerosoleDecayFunctionLinear.intercept
	}

	// MARK: - Internal

	let minutesRange: ENARange
	let slope: Double
	let intercept: Double

}
