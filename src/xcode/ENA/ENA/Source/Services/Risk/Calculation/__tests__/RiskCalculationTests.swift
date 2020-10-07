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

class RiskCalculationTests: XCTestCase {

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
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date(),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.invalid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .inactive)
	}

	func testCalculateRisk_UnknownInitial() {
		// Test the condition when the risk is returned as unknownInitial

		// That will happen when:
		// 1. The number of hours tracing has been active for is less than one day
		// 2. There is no ENExposureDetectionSummary to use

		// Test case for tracing not being active long enough
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)
		var risk = RiskCalculation
			.risk(
				summary: summaryLow,
				configuration: appConfig,
				dateLastExposureDetection: Date(),
				activeTracing: .init(interval: 0),
				preconditions: preconditions(.valid),
				previousRiskLevel: nil,
				providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownInitial)

		// Test case when summary is nil
		risk = RiskCalculation.risk(
			summary: nil,
			configuration: appConfig,
			dateLastExposureDetection: Date(),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownInitial)
	}

	func testCalculateRisk_UnknownOutdated() {
		// Test the condition when the risk is returned as unknownOutdated.

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// That will happen when the date of last exposure detection is older than one day
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownOutdated)
	}

	func testCalculateRisk_UnknownOutdated2() {
		// Test the condition when the risk is returned as unknownOutdated.

		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 2),
			exposureDetectionInterval: .init(day: 2),
			detectionMode: .automatic
		)

		// That will happen when the date of last exposure detection is older than one day
		let risk = RiskCalculation.risk(
			summary: nil,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -1)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownInitial)

		XCTAssertEqual(
			RiskCalculation.risk(
				summary: summaryLow,
				configuration: appConfig,
				dateLastExposureDetection: Date().addingTimeInterval(.init(days: -3)),
				activeTracing: .init(interval: 48 * 3600),
				preconditions: preconditions(.valid),
				previousRiskLevel: nil,
				providerConfiguration: config
				)?.level,
			.unknownOutdated
		)

		XCTAssertEqual(
			RiskCalculation.risk(
				summary: summaryLow,
				configuration: appConfig,
				dateLastExposureDetection: Date().addingTimeInterval(.init(days: -1)),
				activeTracing: .init(interval: 48 * 3600),
				preconditions: preconditions(.valid),
				previousRiskLevel: nil,
				providerConfiguration: config
				)?.level,
			.low
		)
	}


	func testCalculateRisk_LowRisk() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where preconditions pass and there is low risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .low)
	}

	func testCalculateRisk_IncreasedRisk() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		var summary = summaryHigh
		summary.daysSinceLastExposure = 5
		summary.matchedKeyCount = 10

		// Test the case where preconditions pass and there is increased risk
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.details.daysSinceLastExposure, 5)
		XCTAssertEqual(risk?.level, .increased)
	}

	// MARK: - Risk Level Calculation Error Cases

	func testCalculateRisk_OutsideRangeError_Middle() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 5.12 - within a gap in the range
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 128, ad_low: 30, ad_mid: 30, ad_high: 30)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertNil(risk)
	}

	func testCalculateRisk_OutsideRangeError_OffHigh() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 13.6 - outside of the top range of the config
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 255, ad_low: 40, ad_mid: 40, ad_high: 40)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertNil(risk)
	}

	func testCalculateRisk_OutsideRangeError_TooLow() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where preconditions pass and there is increased risk
		// Values below are hand-picked to result in a raw risk score of 0.85 - outside of the bottom bound of the config
		let summary = makeExposureSummaryContainer(maxRiskScoreFullRange: 64, ad_low: 10, ad_mid: 10, ad_high: 10)
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertNil(risk)
	}

}
