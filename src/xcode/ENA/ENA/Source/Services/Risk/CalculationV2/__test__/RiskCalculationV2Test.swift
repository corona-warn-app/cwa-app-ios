//
//  RiscCalculationV2Test.swift
//  ENATests
//
//  Created by Kai-Marcel Teuber on 31.10.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
@testable import ENA

class RiskCalculationV2Test: XCTestCase {

	func testWHEN_LoadingJsonTestFile_THEN_24TestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = testCasesWithConfiguration.testCases

		// THEN
		XCTAssertEqual(testCases.count, 24)
	}

	func testGIVEN_TestCases_WHEN_CalulatingRiskForEachTestCase_THEN_ResultIsCorrect() throws {
		// GIVEN
		let testCases = testCasesWithConfiguration.testCases

		for testCase in testCases {
			// WHEN
			let result = try RiskCalculationV2().calculateRisk(
				exposureWindows: testCase.exposureWindows,
				configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
			)

			// THEN
			XCTAssert(Calendar.current.isDate(result.detectionDate, inSameDayAs: Date()))

			XCTAssertEqual(result.riskLevel, testCase.expTotalRiskLevel.eitherLowOrIncreasedRiskLevel)

			XCTAssertEqual(result.minimumDistinctEncountersWithLowRisk, testCase.expTotalMinimumDistinctEncountersWithLowRisk)
			XCTAssertEqual(result.minimumDistinctEncountersWithHighRisk, testCase.expTotalMinimumDistinctEncountersWithHighRisk)

			XCTAssertEqual(result.ageInDaysOfMostRecentDateWithLowRisk, testCase.expAgeOfMostRecentDateWithLowRisk)
			XCTAssertEqual(result.ageInDaysOfMostRecentDateWithHighRisk, testCase.expAgeOfMostRecentDateWithHighRisk)
		}
	}

	// MARK: - Private

	private lazy var testCasesWithConfiguration: TestCasesWithConfiguration = {
		let testBundle = Bundle(for: RiskCalculationV2Test.self)
		guard let urlJsonFile = testBundle.url(forResource: "exposure-windows-risk-calculation", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			XCTFail("Failed init json file for tests")
			fatalError("Failed init json file for tests - stop hete")
		}

		do {
			return try JSONDecoder().decode(TestCasesWithConfiguration.self, from: data)
		} catch let DecodingError.keyNotFound(jsonKey, context) {
			fatalError("missing key: \(jsonKey)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			fatalError("Type not found \(type)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(type, context) {
			fatalError("Type mismatch found \(type)\nDebug Description: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			fatalError("Debug Description: \(context.debugDescription)")
		} catch {
			fatalError("Failed to parse JSON answer")
		}
	}()

}
