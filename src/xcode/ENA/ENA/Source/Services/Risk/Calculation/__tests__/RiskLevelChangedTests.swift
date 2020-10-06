//
//  RiskLevelChangedTests.swift
//  ENATests
//
//  Created by Vogel, Andreas on 06.10.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

@testable import ENA
import ExposureNotification
import XCTest


// MARK: - RiskLevel changed tests
extension RiskCalculationTests {
	
	func testCalculateRisk_RiskChanged_WithPreviousRisk() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where we have an old risk level in the store,
		// and the new risk level has changed

		// Will produce increased risk
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: .low,
			providerConfiguration: config
		)
		XCTAssertNotNil(risk)
		XCTAssertEqual(risk?.level, .increased)
		XCTAssertTrue(risk?.riskLevelHasChanged ?? false)
	}

	func testCalculateRisk_RiskChanged_NoPreviousRisk() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where we do not have an old risk level in the store,
		// and the new risk level has changed

		// Will produce high risk
		let risk = RiskCalculation.risk(
			summary: summaryHigh,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: nil,
			providerConfiguration: config
		)
		// Going from unknown -> increased or low risk does not produce a change
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_RiskNotChanged() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where we have an old risk level in the store,
		// and the new risk level has not changed

		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			// arbitrary, but within limit
			dateLastExposureDetection: Date().addingTimeInterval(-3600),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: .low,
			providerConfiguration: config
		)

		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_LowToUnknown() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where we have low risk level in the store,
		// and the new risk calculation returns unknown

		// Produces unknown risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: .low,
			providerConfiguration: config
		)
		// The risk level did not change - we only care about changes between low and increased
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}

	func testCalculateRisk_IncreasedToUnknown() {
		let config = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: .init(day: 1),
			exposureDetectionInterval: .init(day: 1),
			detectionMode: .automatic
		)

		// Test the case where we have low risk level in the store,
		// and the new risk calculation returns unknown

		// Produces unknown risk
		let risk = RiskCalculation.risk(
			summary: summaryLow,
			configuration: appConfig,
			dateLastExposureDetection: Date().addingTimeInterval(.init(days: -2)),
			activeTracing: .init(interval: 48 * 3600),
			preconditions: preconditions(.valid),
			previousRiskLevel: .increased,
			providerConfiguration: config
		)
		// The risk level did not change - we only care about changes between low and increased
		XCTAssertFalse(risk?.riskLevelHasChanged ?? true)
	}
}
