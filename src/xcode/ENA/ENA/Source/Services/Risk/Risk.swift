import Foundation

struct Risk: Equatable {
	let level: RiskLevel
	let details: Details
	let riskLevelHasChanged: Bool
}

extension Risk {
	struct Details: Equatable {
		var daysSinceLastExposure: Int?
		var numberOfExposures: Int?
		var numberOfHoursWithActiveTracing: Int { activeTracing.inHours }
		var activeTracing: ActiveTracing
		var numberOfDaysWithActiveTracing: Int { activeTracing.inDays }
		var exposureDetectionDate: Date?
	}
}

#if DEBUG
extension Risk {
	static let mocked = Risk(
		level: .low,
		details: Risk.Details(
			numberOfExposures: 0,
			activeTracing: .init(interval: 336 * 3600),  // two weeks
			exposureDetectionDate: Date()),
		riskLevelHasChanged: true
	)
}
#endif
