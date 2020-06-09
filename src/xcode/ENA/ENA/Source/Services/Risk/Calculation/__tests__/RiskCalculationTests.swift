//
// Corona-Warn-App
//
// SAP SE and all other contributors
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

@testable import ENA
import ExposureNotification
import XCTest

final class RiskCalculationTests: XCTestCase {

	private let store = MockTestStore()

	// MARK: - Tests for calculating raw risk score

	func testCalculateRawRiskScore_Zero() throws {
		let summaryZeroMaxRisk = makeExposureSummaryContainer(maxRiskScoreFullRange: 0, ad_low: 10, ad_mid: 10, ad_high: 10)
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryZeroMaxRisk, configuration: appConfig), 0.0, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_Low() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryLow, configuration: appConfig), 1.07, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_Med() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryMed, configuration: appConfig), 2.56, accuracy: 0.01)
	}

	func testCalculateRawRiskScore_High() throws {
		XCTAssertEqual(RiskCalculation.calculateRawRisk(summary: summaryHigh, configuration: appConfig), 10.2, accuracy: 0.01)
	}

	// MARK: - Tests for calculating risk levels

	func testCalculateRisk_Inactive() {
		// Test the condition when the risk is returned as inactive
		// This occurs when the preconditions are not met, ex. when tracing is off.
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date(),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.invalid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .inactive)
	}

	func testCalculateRisk_UnknownInitial() {
		// Test the condition when the risk is returned as unknownInitial

		// That will happen when:
		// 1. The number of hours tracing has been active for is less than one day
		// 2. There is no ENExposureDetectionSummary to use

		// Test case for tracing not being active long enough
		var risk = RiskCalculation
			.risk(
				summary: summaryLow,
				configuration: appConfig,
				dateLastExposureDetection: Date(),
				numberOfTracingActiveHours: 0,
				preconditions: preconditions(.valid),
				previousRiskLevel: nil
			)

		XCTAssertEqual(risk?.level, .unknownInitial)

		// Test case when summary is nil
		risk = RiskCalculation.risk(
			summary: nil,
			configuration: appConfig,
			dateLastExposureDetection: Date(),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .unknownInitial)
	}

	func testCalculateRisk_UnknownOutdated() {
		// Test the condition when the risk is returned as unknownOutdated.

		// That will happen when the date of last exposure detection is older than one day
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .unknownOutdated)
	}

	func testCalculateRisk_LowRisk() {
		// Test the case where preconditions pass and there is low risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .low)
	}

	func testCalculateRisk_IncreasedRisk() {
		// Test the case where preconditions pass and there is increased risk
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .increased)
	}

	// MARK: - Risk Level Calculation Error Cases

	func testCalculateRisk_OutsideRangeError_Middle() {
		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 5.12 - within a gap in the range
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 128, ad_low: 30, ad_mid: 30, ad_high: 30)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertNil(risk)
	}

	func testCalculateRisk_OutsideRangeError_OffHigh() {
		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 13.6 - outside of the top range of the config
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 255, ad_low: 40, ad_mid: 40, ad_high: 40)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertNil(risk)
	}

	func testCalculateRisk_OutsideRangeError_TooLow() {
		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 0.85 - outside of the bottom bound of the config
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 64, ad_low: 10, ad_mid: 10, ad_high: 10)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertNil(risk)
	}

	// MARK: - Risk Level Calculation Hierarchy Tests

	// There is a certain order to risk levels, and some override others. This is tested below.

	func testCalculateRisk_IncreasedOverridesUnknownOutdated() {
		// Test case where last exposure summary was gotten too far in the past,
		// But the risk is increased
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .increased)
	}

	func testCalculateRisk_UnknownInitialOverridesUnknownOutdated() {
		// Test case where last exposure summary was gotten too far in the past,
		let risk = RiskCalculation.risk(
			summary: nil,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)

		XCTAssertEqual(risk?.level, .unknownInitial)
	}

	// MARK: - RiskLevel changed tests

	func testCalculateRisk_RiskChanged_WithPreviousRisk() {
		// Test the case where we have an old risk level in the store,
		// and the new risk level has changed
		let previousRiskLevel = EitherLowOrIncreasedRiskLevel.low

		// Will produce increased risk
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: previousRiskLevel
		)

		XCTAssertTrue(risk?.riskLevelHasChanged ?? false)
	}

	func testCalculateRisk_RiskChanged_NoPreviousRisk() {
		// Test the case where we do not have an old risk level in the store,
		// and the new risk level has changed

		// Will produce high risk
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: nil
		)
		// Going from unknown -> increased or low risk does not produce a change
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_RiskNotChanged() {
		// Test the case where we have an old risk level in the store,
		// and the new risk level has not changed
		let previousRiskLevel = EitherLowOrIncreasedRiskLevel.low

		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: previousRiskLevel
		)

		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_LowToUnknown() {
		// Test the case where we have low risk level in the store,
		// and the new risk calculation returns unknown
		let previousRiskLevel = EitherLowOrIncreasedRiskLevel.low

		// Produces unknown risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: previousRiskLevel
		)
		// The risk level did not change - we only care about changes between low and increased
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_IncreasedToUnknown() {
		// Test the case where we have low risk level in the store,
		// and the new risk calculation returns unknown
		let previousRiskLevel = EitherLowOrIncreasedRiskLevel.increased

		// Produces unknown risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			numberOfTracingActiveHours: 48,
			preconditions: preconditions(.valid),
			previousRiskLevel: previousRiskLevel
		)
		// The risk level did not change - we only care about changes between low and increased
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}
}

// MARK: - Helpers

private extension RiskCalculationTests {

	private var appConfig: SAP_ApplicationConfiguration {
		makeAppConfig(w_low: 1.0, w_med: 0.5, w_high: 0.5)
	}

	private var summaryLow: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 80, ad_low: 10, ad_mid: 10, ad_high: 10)
	}

	private var summaryMed: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 128, ad_low: 15, ad_mid: 15, ad_high: 15)
	}

	private var summaryHigh: CodableExposureDetectionSummary {
		makeExposureSummaryContainer(maxRiskScoreFullRange: 255, ad_low: 30, ad_mid: 30, ad_high: 30)
	}

	enum PreconditionState {
		case valid
		case invalid
	}

	private func preconditions(_ state: PreconditionState) -> ExposureManagerState {
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

	private func makeExposureSummaryContainer(
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
	private func makeAppConfig(
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

private extension TimeInterval {
	init(days: Int) {
		self = Double(days * 24 * 60 * 60)
	}
}
