//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import ExposureNotification
import UIKit

enum RiskCalculation {

	// MARK: - Precondition Time Constants

	/// Minimum duration (in hours) that tracing has to be active for in order to perform a valid risk calculation
	static let minTracingActiveHours = TracingStatusHistory.minimumActiveHours
	/// Count of days until a previously calculated exposure detection is considered outdated
	static let exposureDetectionStaleThreshold = 2

	// MARK: - Risk Calculation Functions

	/**
	Calculates the risk level of the user

	Preconditions:
	1. Check that notification exposure is turned on (via preconditions) on If not, `.inactive`
	2. Check tracingActiveHours >= 24 (needs to be active for 24hours) If not, `.unknownInitial`
	3. Check if ExposureDetectionSummaryContainer is there. If not, `.unknownInitial`
	4. Check dateLastExposureDetection is less than 2 days ago. If not `.unknownOutdated`

	Everything needed for the calculation is passed in,
	no async work needed

	Until RKI formula can be implemented:
	Once all preconditions above are passed, simply use the `maximumRiskScore` from the injected `ENExposureDetectionSummaryContainer`

	- parameters:
		- summary: The latest `ENExposureDetectionSummaryContainer`, `nil` if it does not exist
		- configuration: The latest `ENExposureConfiguration`
		- dateLastExposureDetection: The date of the most recent exposure detection
		- numberOfTracingActiveDays: A count of how many days tracing has been active for
		- preconditions: Current state of the `ExposureManager`
		- currentDate: The current `Date` to use in checks. Defaults to `Date()`
	*/
	private static func riskLevel(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing, // Get this from the `TracingStatusHistory`
		preconditions: ExposureManagerState,
		providerConfiguration: RiskProvidingConfiguration,
		currentDate: Date = Date()
	) -> Result<RiskLevel, RiskLevelCalculationError> {
		DispatchQueue.main.async {
			let appDelegate = UIApplication.shared.delegate as? AppDelegate // TODO: Remove
			appDelegate?.lastRiskCalculation = ""  // Reset; Append from here on
			appDelegate?.lastRiskCalculation.append("configuration: \(configuration)\n")
			appDelegate?.lastRiskCalculation.append("numberOfTracingActiveHours: \(activeTracing.inHours)\n")
			appDelegate?.lastRiskCalculation.append("preconditions: \(preconditions)\n")
			appDelegate?.lastRiskCalculation.append("currentDate: \(currentDate)\n")
			appDelegate?.lastRiskCalculation.append("summary: \(String(describing: summary?.description))\n")
		}

		//
		// Precondition 1 - Exposure Notifications must be turned on
		let isInactive = !preconditions.isGood

		// Precondition 2 - If tracing is active less than 1 day, risk is .unknownInitial
		let isTracingActiveLess1Day = activeTracing.inHours < minTracingActiveHours

		// Precondition 3 - Risk is unknownInitial if summary is not present
		let isNoSummary = summary == nil

		let isUnknownInitial = isTracingActiveLess1Day || isNoSummary

		let isUnknownOutdated = !providerConfiguration.exposureDetectionIsValid(lastExposureDetectionDate: dateLastExposureDetection ?? .distantPast)

		var riskLevels: [RiskLevel] = [.low]

		// returns RiskLevel with higher priority
		var riskLevel: RiskLevel {
			riskLevels.max() ?? .inactive
		}

		if isInactive { riskLevels.append(.inactive) }
		if isUnknownOutdated { riskLevels.append(.unknownOutdated) }
		if isUnknownInitial { riskLevels.append(.unknownInitial) }

		guard let summary = summary else { return .success(riskLevel) }

		// Calculation low & increased risk levels
		let riskScoreClasses = configuration.riskScoreClasses
		let riskClasses = riskScoreClasses.riskClasses

		guard
			let riskScoreClassLow = riskClasses.low,
			let riskScoreClassHigh = riskClasses.high
		else {
			return .failure(.undefinedRiskRange)
		}

		let riskRangeLow = Double(riskScoreClassLow.min)..<Double(riskScoreClassLow.max)
		let riskRangeHigh = Double(riskScoreClassHigh.min)...Double(riskScoreClassHigh.max)

		let riskScore = calculateRawRisk(summary: summary, configuration: configuration)

		var isLow = false
		var isIncreased = false

		if riskRangeLow.contains(riskScore) {
			isLow = true
		} else if riskRangeHigh.contains(riskScore) {
			isIncreased = true
		} else {
			return .failure(.riskOutsideRange)
		}

		if isLow { riskLevels.append(.low) }
		if isIncreased { riskLevels.append(.increased) }

		// Depending on different conditions we return riskLevel
		let state = (isUnknownOutdated, isIncreased, isUnknownInitial)
		switch state {
		case (true, true, false):
			return .success(.unknownOutdated)
		case (_, _, _):
			return .success(riskLevel)
		}
	}

	/// Performs the raw risk calculation without checking any preconditions
	/// - returns: weighted risk score
	static func calculateRawRisk(
		summary: CodableExposureDetectionSummary,
		configuration: SAP_ApplicationConfiguration
	) -> Double {
		// "Fig" comments below point to figures in the docs: https://github.com/corona-warn-app/cwa-documentation/blob/master/solution_architecture.md#risk-score-calculation
		let maximumRisk = summary.maximumRiskScoreFullRange
		let adWeights = configuration.attenuationDuration.weights
		let attenuationDurationsInMin = summary.configuredAttenuationDurations.map { $0 / Double(60.0) }
		let attenuationConfig = configuration.attenuationDuration
		// Fig 13 - 2
		let normRiskScore = Double(maximumRisk) / Double(attenuationConfig.riskScoreNormalizationDivisor)
		// Fig 13 - 1
		let weightedAttenuationDurationsLow = attenuationDurationsInMin[0] * adWeights.low
		let weightedAttenuationDurationsMid = attenuationDurationsInMin[1] * adWeights.mid
		let weightedAttenuationDurationsHigh = attenuationDurationsInMin[2] * adWeights.high
		let bucketOffset = Double(attenuationConfig.defaultBucketOffset)
		// Fig 13 - 1
		let weightedAttenuation = weightedAttenuationDurationsLow + weightedAttenuationDurationsMid + weightedAttenuationDurationsHigh + bucketOffset

		// TODO: Remove
		DispatchQueue.main.async {
			let appDelegate = UIApplication.shared.delegate as? AppDelegate
			appDelegate?.lastRiskCalculation.append("\n ===== Calculation =====\n")
			appDelegate?.lastRiskCalculation.append("normRiskScore: \(normRiskScore)\n")
			appDelegate?.lastRiskCalculation.append("weightedAttenuationDurationsLow: \(weightedAttenuationDurationsLow)\n")
			appDelegate?.lastRiskCalculation.append("weightedAttenuationDurationsMid: \(weightedAttenuationDurationsMid)\n")
			appDelegate?.lastRiskCalculation.append("weightedAttenuationDurationsHigh: \(weightedAttenuationDurationsHigh)\n")
			appDelegate?.lastRiskCalculation.append("bucketOffset: \(bucketOffset)\n")
			appDelegate?.lastRiskCalculation.append("weightedAttenuation: \(weightedAttenuation)\n")
			appDelegate?.lastRiskCalculation.append("Final result: \((normRiskScore * weightedAttenuation).rounded(to: 2))\n")
		}

		// Round to two decimal places
		return (normRiskScore * weightedAttenuation).rounded(to: 2)
	}

	static func risk(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing,
		preconditions: ExposureManagerState,
		currentDate: Date = Date(),
		previousRiskLevel: EitherLowOrIncreasedRiskLevel?,
		providerConfiguration: RiskProvidingConfiguration
	) -> Risk? {
		switch riskLevel(
			summary: summary,
			configuration: configuration,
			dateLastExposureDetection: dateLastExposureDetection,
			activeTracing: activeTracing,
			preconditions: preconditions,
			providerConfiguration: providerConfiguration
		) {
		case .success(let level):
			let keyCount = summary?.matchedKeyCount ?? 0
			let daysSinceLastExposure = keyCount > 0 ? summary?.daysSinceLastExposure : nil
			let details = Risk.Details(
				daysSinceLastExposure: daysSinceLastExposure,
				numberOfExposures: Int(summary?.matchedKeyCount ?? 0),
				activeTracing: activeTracing,
				exposureDetectionDate: dateLastExposureDetection ?? Date()
			)

			DispatchQueue.main.async {
				// TODO: Remove
				let appDelegate = UIApplication.shared.delegate as? AppDelegate
				appDelegate?.lastRiskCalculation.append("\n ===== Risk =====\n")
				appDelegate?.lastRiskCalculation.append("details: \(details)\n")
				appDelegate?.lastRiskCalculation.append("summary: \(String(describing: summary?.description))\n")
			}

			var riskLevelHasChanged = false
			if
				let previousRiskLevel = previousRiskLevel,
				let newRiskLevel = EitherLowOrIncreasedRiskLevel(with: level),
				previousRiskLevel != newRiskLevel {
				// If the newly calculated risk level is different than the stored level, set the flag to true.
				// Note that we ignore all levels aside from low or increased risk
				riskLevelHasChanged = true
			}
			
			return Risk(
				level: level,
				details: details,
				riskLevelHasChanged: riskLevelHasChanged
			)
		case .failure:
			return nil
		}
	}
}

// MARK: - Risk Level Calculation Errors

enum RiskLevelCalculationError: Error {
	case riskOutsideRange
	case undefinedRiskRange
}

// MARK: - Helpers

extension Double {
	func rounded(to places: Int) -> Double {
		let factor = pow(10, Double(places))
		return (self * factor).rounded() / factor
	}
}
