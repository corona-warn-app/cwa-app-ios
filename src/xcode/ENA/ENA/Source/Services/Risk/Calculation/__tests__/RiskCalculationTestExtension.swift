//
//  RiskCalculationTestExtension.swift
//  ENATests
//
//  Created by Vogel, Andreas on 06.10.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

@testable import ENA

import ExposureNotification
import XCTest


extension RiskCalculationTests {

	var appConfig: SAP_ApplicationConfiguration {
		makeAppConfig(w_low: 1.0, w_med: 0.5, w_high: 0.5)
	}

	var summaryLow: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 80, ad_low: 10, ad_mid: 10, ad_high: 10)
	}

	var summaryMed: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 128, ad_low: 15, ad_mid: 15, ad_high: 15)
	}

	var summaryHigh: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 255, ad_low: 30, ad_mid: 30, ad_high: 30)
	}

	enum PreconditionState {
		case valid
		case invalid
	}

	func preconditions(_ state: PreconditionState) -> ExposureManagerState {
		switch state {
		case .valid:
			return .init(
				authorized: true,
				enabled: true,
				status:
				.active
			)
		default:
			return .init(authorized: true, enabled: false, status: .disabled)
		}
	}

	func makeExposureSummaryContainer(
		maxRiskScoreFullRange: Int,
		ad_low: Double,
		ad_mid: Double,
		ad_high: Double
	) -> CodableExposureDetectionSummary {
		.init(
			daysSinceLastExposure: 0,
			matchedKeyCount: 0,
			maximumRiskScore: 0,
			attenuationDurations: [ad_low, ad_mid, ad_high],
			maximumRiskScoreFullRange: maxRiskScoreFullRange
		)
	}

	/// Makes an mock `SAP_ApplicationConfiguration`
	///
	/// Some defaults are applied for ad_norm, w4, and low & high ranges
	func makeAppConfig(
		ad_norm: Int32 = 25,
		w4: Int32 = 0,
		w_low: Double,
		w_med: Double,
		w_high: Double,
		riskRangeLow: ClosedRange<Int32> = 1...5,
		// Gap between the ranges is on purpose, this is an edge case to test
		riskRangeHigh: Range<Int32> = 6..<11
	) -> SAP_ApplicationConfiguration {
		var config = SAP_ApplicationConfiguration()
		config.attenuationDuration.defaultBucketOffset = w4
		config.attenuationDuration.riskScoreNormalizationDivisor = ad_norm
		config.attenuationDuration.weights.low = w_low
		config.attenuationDuration.weights.mid = w_med
		config.attenuationDuration.weights.high = w_high

		var riskScoreClassLow = SAP_RiskScoreClass()
		riskScoreClassLow.label = "LOW"
		riskScoreClassLow.min = riskRangeLow.lowerBound
		riskScoreClassLow.max = riskRangeLow.upperBound

		var riskScoreClassHigh = SAP_RiskScoreClass()
		riskScoreClassHigh.label = "HIGH"
		riskScoreClassHigh.min = riskRangeHigh.lowerBound
		riskScoreClassHigh.max = riskRangeHigh.upperBound

		config.riskScoreClasses.riskClasses = [
			riskScoreClassLow,
			riskScoreClassHigh
		]

		return config
	}
}
