//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

struct ExposureWindowTestCase: Decodable {

	// MARK: - Internal

	let description: String
	let exposureWindows: [ExposureWindow]
	let expTotalRiskLevel: RiskLevel
	let expTotalMinimumDistinctEncountersWithLowRisk: Int
	let expTotalMinimumDistinctEncountersWithHighRisk: Int
	let expAgeOfMostRecentDateWithLowRisk: Int?
	let expAgeOfMostRecentDateWithHighRisk: Int?
	let expNumberOfDaysWithLowRisk: Int
	let expNumberOfDaysWithHighRisk: Int

}
