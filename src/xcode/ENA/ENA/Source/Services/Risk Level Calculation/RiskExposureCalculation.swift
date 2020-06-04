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

enum RiskExposureCalculation {

	/**
	Calculates the risk level of the user

	Preconditions:
	1. Check that notification exposure is turned on (via preconditions) on If not, `.inactive`
	2. Check tracingActiveDays >= 1 (needs to be active for 24hours) If not, `.unknownInitial`
	3. Check if ExposureDetectionSummaryContainer is there. If not, `.unknownInitial`
	4. Check dateLastExposureDetection is less than 24h ago. If not `.unknownOutdated`

	Everything needed for the calculation is passed in,
	no async work needed

	Until RKI formula can be implemented:
	Once all preconditions above are passed, simply use the `maximumRiskScore` from the injected `ENExposureDetectionSummaryContainer`

	- parameters:
		- summary: The lastest `ENExposureDetectionSummaryContainer`, `nil` if it does not exist
		- configuration: The latest `ENExposureConfiguration`
		- dateLastExposureDetection: The date of the most recent exposure detection
		- numberOfTracingActiveDays: A count of how many days tracing has been active for
		- preconditions: Current state of the `ExposureManager`
		- currentDate: The current `Date` to use in checks. Defaults to `Date()`
	*/
	static func riskLevel(
		summary: ENExposureDetectionSummaryContainer?,
		configuration: SAP_ApplicationConfiguration,
//		exposureDetectionValidityDuration: DateComponents,
		dateLastExposureDetection: Date?,
		numberOfTracingActiveDays: Int, // Get this from the `TracingStatusHistory`
		preconditions: ExposureManagerState,
		currentDate: Date = Date()
	) -> Result<RiskLevel, RiskLevelCalculationError> {
		var riskLevel = RiskLevel.low
		// Precondition 1 - Exposure Notifications must be turned on
		guard preconditions.isGood else {
			// This overrides all other levels
			return .success(.inactive)
		}

		// Precondition 2 - If tracing is active less than 1 day, risk is .unknownInitial
		if numberOfTracingActiveDays < 1, riskLevel < .unknownInitial {
			riskLevel = .unknownInitial
		}

		// Precondition 3 - Risk is unknownInitial if summary is not present
		if summary == nil, riskLevel < .unknownInitial {
			// TODO: Early return?
			riskLevel = .unknownInitial
		}

		// Precondition 4 - If date of last exposure detection was not within 1 day, risk is unknownOutdated
		if
			let dateLastExposureDetection = dateLastExposureDetection,
			!dateLastExposureDetection.isWithinExposureDetectionValidInterval(from: currentDate),
			riskLevel < .unknownOutdated
		{
			riskLevel = .unknownOutdated
		}

		guard let summary = summary else {
			// TODO: Is this correct, need to test
			return .success(.unknownOutdated)
		}

		/* Android:
		val maxRisk = it.exposureSummary?.maximumRiskScore
		val atWeights = it.appConfig?.attenuationDuration?.weights
		val attenuationDurationInMin =
			it.exposureSummary?.attenuationDurationsInMinutes
		val attenuationConfig = it.appConfig?.attenuationDuration
		val formulaString =
			"($maxRisk / ${attenuationConfig?.riskScoreNormalizationDivisor}) * " +
					"(${attenuationDurationInMin?.get(0)} * ${atWeights?.low} " +
					"+ ${attenuationDurationInMin?.get(1)} * ${atWeights?.mid} " +
					"+ ${attenuationDurationInMin?.get(2)} * ${atWeights?.high} " +
					"+ ${attenuationConfig?.defaultBucketOffset})"
		*/

		guard
			let riskScoreClassLow = configuration.riskScoreClasses.riskClasses.first(where: { $0.label == "LOW" }),
			let riskScoreClassHigh = configuration.riskScoreClasses.riskClasses.first(where: { $0.label == "HIGH" })
		else {
			return .failure(.undefinedRiskRange)
		}

		let riskRangeLow = Range<Double>(uncheckedBounds: (lower: Double(riskScoreClassLow.min), upper: Double(riskScoreClassLow.max)))
		let riskRangeHigh = Range<Double>(uncheckedBounds: (lower: Double(riskScoreClassHigh.min), upper: Double(riskScoreClassHigh.max)))

		let maximumRisk = summary.maximumRiskScore
		let adWeights = configuration.attenuationDuration.weights
		let attenuationDurations = summary.configuredAttenuationDurations
		let attenuationConfig = configuration.attenuationDuration

		let normRiskScore = Double(maximumRisk) / Double(attenuationConfig.riskScoreNormalizationDivisor)
		let weightedAttenuationDurationsLow = attenuationDurations[0] / Double(60.0) * adWeights.low
		let weightedAttenuationDurationsMid = attenuationDurations[1] / Double(60.0) * adWeights.mid
		let weightedAttenuationDurationsHigh = attenuationDurations[2] / Double(60.0) * adWeights.high
		let bucketOffset = Double(attenuationConfig.defaultBucketOffset)

		let riskScore = normRiskScore * (weightedAttenuationDurationsLow * weightedAttenuationDurationsMid * weightedAttenuationDurationsHigh + bucketOffset)

		if riskRangeLow.contains(riskScore) {
			let calculatedRiskLevel = RiskLevel.low
			// Only use the calculated risk level if it is of a higher priority than the
			riskLevel = calculatedRiskLevel > riskLevel ? calculatedRiskLevel : riskLevel
		} else if riskRangeHigh.contains(riskScore) {
			let calculatedRiskLevel = RiskLevel.increased
			riskLevel = calculatedRiskLevel > riskLevel ? calculatedRiskLevel : riskLevel
		} else {
			return .failure(.riskOutsideRange)
		}

		return .success(riskLevel)
	}
}

enum RiskLevelCalculationError: Error {
	case riskOutsideRange
	case undefinedRiskRange
}

extension Date {
	func isWithinExposureDetectionValidInterval(from date: Date = Date()) -> Bool {
		Calendar.current.dateComponents(
			[.day],
			from: date,
			to: self
		).day ?? .max < 1
	}
}
