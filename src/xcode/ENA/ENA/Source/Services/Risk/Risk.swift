//
// 🦠 Corona-Warn-App
//

import Foundation

struct Risk: Equatable {
	let level: RiskLevel
	let details: Details
	let riskLevelHasChanged: Bool
}

extension Risk {
	struct Details: Equatable {
		var mostRecentDateWithRiskLevel: Date?
		var numberOfDaysWithRiskLevel: Int
		var numberOfHoursWithActiveTracing: Int { activeTracing.inHours }
		var activeTracing: ActiveTracing
		var numberOfDaysWithActiveTracing: Int { activeTracing.inDays }
		var exposureDetectionDate: Date?
	}
}

#if DEBUG
extension Risk {
	static let mocked = Risk(
		// UITests can set app.launchArguments "-riskLevel"
		level: .high, //UserDefaults.standard.string(forKey: "riskLevel") == "high" ? .high : .low,
		details: Risk.Details(
			mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
			numberOfDaysWithRiskLevel: UserDefaults.standard.string(forKey: "riskLevel") == "high" ? 1 : 0,
			activeTracing: .init(interval: 336 * 3600),  // two weeks
			exposureDetectionDate: Date()),
		riskLevelHasChanged: true
	)
}
#endif
