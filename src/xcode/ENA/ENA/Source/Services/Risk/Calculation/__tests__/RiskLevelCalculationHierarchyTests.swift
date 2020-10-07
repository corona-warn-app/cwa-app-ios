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


// MARK: Risk Level Calculation Hierarchy Tests
// There is a certain order to risk levels, and some override others. This is tested below.

extension RiskCalculationTests {
	
	func testCalculateRisk_UnknownOutdatedOverridesIncreased() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test case where last exposure summary was gotten too far in the past,
		// But the risk is increased
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownOutdated)
		XCTAssertTrue(risk?.riskLevelHasChanged == false)
	}

	func testCalculateRisk_IncreasedOverridesUnknownOutdated() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test case where last exposure summary was gotten less then 1 day
		// Active tracing is more then 24h
		// But the risk is increased
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(hours: -23)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .increased)
		XCTAssertTrue(risk?.riskLevelHasChanged == false)
	}

	func testCalculateRisk_IncreasedOverridesUnknownOutdated2() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test case where last exposure summary was gotten more then 1 day
		// Active tracing is less then 24h
		// But the risk is increased
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(hours: -25)),
			activeTracing: .init(interval: 2 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .increased)
		XCTAssertTrue(risk?.riskLevelHasChanged == false)
	}

	func testCalculateRisk_IncreasedOverridesUnknownOutdated3() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test case where last exposure summary was gotten less then 1 day
		// Active tracing is less then 24h
		// But the risk is increased
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(hours: -23)),
			activeTracing: .init(interval: 2 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .increased)
		XCTAssertTrue(risk?.riskLevelHasChanged == false)
	}

	func testCalculateRisk_UnknownInitialOverridesUnknownOutdated() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test case where last exposure summary was gotten too far in the past,
		let risk = RiskCalculation.risk(
			summary: nil,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)

		XCTAssertEqual(risk?.level, .unknownInitial)
	}
}
