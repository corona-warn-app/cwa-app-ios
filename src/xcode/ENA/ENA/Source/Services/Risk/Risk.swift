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
		var exposureDetectionDate: Date?
	}
}

#if DEBUG
extension Risk {
	static let numberOfDaysWithRiskLevel = (UserDefaults.standard.string(forKey: "numberOfDaysWithRiskLevel") as NSString?)?.integerValue
	static let numberOfDaysWithRiskLevelDefaultValue: Int = UserDefaults.standard.string(forKey: "riskLevel") == "high" ? 1 : 0
	static let mocked = Risk(
		// UITests can set app.launchArguments "-riskLevel"
		level: UserDefaults.standard.string(forKey: "riskLevel") == "high" ? .high : .low,
		details: Risk.Details(
			mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
			numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel ?? numberOfDaysWithRiskLevelDefaultValue,
			exposureDetectionDate: Date()),
		riskLevelHasChanged: true
	)

	static func mocked(
		level: RiskLevel = .low) -> Risk {
		Risk(
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel ?? numberOfDaysWithRiskLevelDefaultValue,
				exposureDetectionDate: Date()),
			riskLevelHasChanged: true
		)
	}
}
#endif
