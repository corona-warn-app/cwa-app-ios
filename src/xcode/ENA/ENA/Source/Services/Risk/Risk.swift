//
// 🦠 Corona-Warn-App
//

import Foundation

struct Risk: Equatable {

	struct Details: Equatable {
		var mostRecentDateWithRiskLevel: Date?
		var numberOfDaysWithRiskLevel: Int
		var calculationDate: Date?
	}

	enum RiskLevelChange: Equatable {
		case increased
		case decreased
		case unchanged(RiskLevel)
	}

	let level: RiskLevel
	let details: Details
	let riskLevelHasChanged: Bool
	let riskLevelChange: RiskLevelChange
}

extension Risk {
	init(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		previousENFRiskCalculationResult: ENFRiskCalculationResult? = nil,
		checkinCalculationResult: CheckinRiskCalculationResult,
		previousCheckinCalculationResult: CheckinRiskCalculationResult? = nil
	) {
		Log.info("[Risk] Merging risks from ENF and checkin. Create Risk.", log: .riskDetection)

		// determine if global risk level has changed
		let riskLevelHasChanged = previousENFRiskCalculationResult?.riskLevel != nil &&
			enfRiskCalculationResult.riskLevel != previousENFRiskCalculationResult?.riskLevel ||
			previousCheckinCalculationResult?.riskLevel != nil &&
			checkinCalculationResult.riskLevel != previousCheckinCalculationResult?.riskLevel

		Log.debug("[Risk] riskLevelHasChanged: \(riskLevelHasChanged)", log: .riskDetection)
		
		// Check for each risk source (enf and checkin) if one of them got high. Only needed for PPA.
		if previousENFRiskCalculationResult?.riskLevel == .low &&
			enfRiskCalculationResult.riskLevel == .high {
			Log.debug("[Risk] ENF riskLevel has changed to high.", log: .riskDetection)
			Analytics.collect(.testResultMetadata(.setDateOfConversionToENFHighRisk(Date())))
		}
		if previousCheckinCalculationResult?.riskLevel == .low &&
			checkinCalculationResult.riskLevel == .high {
			Log.debug("[Risk] Checkin riskLevel has changed to high.", log: .riskDetection)
			Analytics.collect(.testResultMetadata(.setDateOfConversionToCheckinHighRisk(Date())))
		}

		let tracingRiskLevelPerDate = enfRiskCalculationResult.riskLevelPerDate
		let checkinRiskLevelPerDate = checkinCalculationResult.riskLevelPerDate

		Log.debug("[Risk] tracingRiskLevelPerDate: \(tracingRiskLevelPerDate)", log: .riskDetection)
		Log.debug("[Risk] checkinRiskLevelPerDate: \(checkinRiskLevelPerDate)", log: .riskDetection)

		// Merge the results from both risk calculation. For each date, the higher risk level is used.
		let mergedRiskLevelPerDate = tracingRiskLevelPerDate.merging(checkinRiskLevelPerDate) { lhs, rhs -> RiskLevel in
			max(lhs, rhs)
		}

		Log.debug("[Risk] mergedRiskLevelPerDate: \(mergedRiskLevelPerDate)", log: .riskDetection)

		// The Total Risk Level is High if there is least one Date with Risk Level per Date calculated as High; it is Low otherwise.
		var totalRiskLevel: RiskLevel = .low
		if mergedRiskLevelPerDate.contains(where: {
			$0.value == .high
		}) {
			totalRiskLevel = .high
		}

		Log.debug("[Risk] totalRiskLevel: \(totalRiskLevel)", log: .riskDetection)

		// 1. Filter for the desired risk.
		// 2. Select the maximum by date (the most current).
		let mostRecentDateWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == totalRiskLevel
		}.max(by: {
			$0.key < $1.key
		})?.key

		Log.debug("[Risk] mostRecentDateWithRiskLevel: \(String(describing: mostRecentDateWithRiskLevel))", log: .riskDetection)

		let numberOfDaysWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == totalRiskLevel
		}.count

		Log.debug("[Risk] numberOfDaysWithRiskLevel: \(numberOfDaysWithRiskLevel)", log: .riskDetection)

		let calculationDate = max(enfRiskCalculationResult.calculationDate, checkinCalculationResult.calculationDate)

		let details = Details(
			mostRecentDateWithRiskLevel: mostRecentDateWithRiskLevel,
			numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
			calculationDate: calculationDate
		)

		// determine global risk level change type
		let riskLevelChange: RiskLevelChange
		if riskLevelHasChanged {
			riskLevelChange = totalRiskLevel == .high ? .increased : .decreased
		} else {
			riskLevelChange = .unchanged(totalRiskLevel)
		}

		self.init(
			level: totalRiskLevel,
			details: details,
			riskLevelHasChanged: riskLevelHasChanged,
			riskLevelChange: riskLevelChange
		)
	}
}

#if DEBUG
extension Risk {
	static let numberOfDaysWithRiskLevel = LaunchArguments.risk.numberOfDaysWithRiskLevel.intValue
	static let numberOfDaysWithRiskLevelDefaultValue: Int = LaunchArguments.risk.riskLevel.stringValue == "high" ? 1 : 0
	static let mocked: Risk = {
		let level: RiskLevel = LaunchArguments.risk.riskLevel.stringValue == "high" ? .high : .low
		return Risk(
			// UITests can set app.launchArguments LaunchArguments.risk.riskLevel
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
				calculationDate: Date()),
			riskLevelHasChanged: true,
			riskLevelChange: level == .high ? .increased : .decreased
		)
	}()

	static func mocked(
		level: RiskLevel = .low,
		riskLevelChange: RiskLevelChange = .decreased
	) -> Risk {
		Risk(
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
				calculationDate: Date()),
			riskLevelHasChanged: true,
			riskLevelChange: riskLevelChange
		)
	}
}
#endif
