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
		level: UserDefaults.standard.string(forKey: "riskLevel") == "high" ? .high : .low,
		details: Risk.Details(
			mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
			numberOfDaysWithRiskLevel: UserDefaults.standard.string(forKey: "riskLevel") == "high" ? 1 : 0,
			/*
			 * We need to first cast it as NSString to get a doubleValue because
			 * string don't support that conversion
			 * The default value is 14 days if the lauch argument is not given
			 * 24 x 3600 because a days has 24 hours and each hour has 3600 seconds
			 */
			activeTracing: .init(interval: ((UserDefaults.standard.string(forKey: "activeTracingDays") as NSString?)?.doubleValue ?? 14) * 24 * 3600),
			exposureDetectionDate: Date()),
		riskLevelHasChanged: true
	)
}
#endif
