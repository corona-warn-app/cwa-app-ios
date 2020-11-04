import Foundation
import ExposureNotification
import UIKit

protocol RiskCalculationProtocol {

	func risk(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_Internal_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing,
		preconditions: ExposureManagerState,
		previousRiskLevel: EitherLowOrIncreasedRiskLevel?,
		providerConfiguration: RiskProvidingConfiguration
	) -> Risk?
}

struct RiskCalculation: RiskCalculationProtocol {

	// MARK: - Precondition Time Constants

	/// Minimum duration (in hours) that tracing has to be active for in order to perform a valid risk calculation
	let minTracingActiveHours = TracingStatusHistory.minimumActiveHours
	/// Count of days until a previously calculated exposure detection is considered outdated
	let exposureDetectionStaleThreshold = 2

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
	*/
	private func riskLevel(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_Internal_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing, // Get this from the `TracingStatusHistory`
		preconditions: ExposureManagerState,
		providerConfiguration: RiskProvidingConfiguration
	) -> Result<RiskLevel, RiskLevelCalculationError> {

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

		var isIncreased = false

		if riskRangeLow.contains(riskScore) {
			riskLevels.append(.low)
		} else if riskRangeHigh.contains(riskScore) {
			isIncreased = true
			riskLevels.append(.increased)
		} else {
			return .failure(.riskOutsideRange)
		}

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
	func calculateRawRisk(
		summary: CodableExposureDetectionSummary,
		configuration: SAP_Internal_ApplicationConfiguration
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

		// Round to two decimal places
		return (normRiskScore * weightedAttenuation).rounded(to: 2)
	}

	func risk(
		summary: CodableExposureDetectionSummary?,
		configuration: SAP_Internal_ApplicationConfiguration,
		dateLastExposureDetection: Date?,
		activeTracing: ActiveTracing,
		preconditions: ExposureManagerState,
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

			var riskLevelHasChanged = false
			if let previousRiskLevel = previousRiskLevel,
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
