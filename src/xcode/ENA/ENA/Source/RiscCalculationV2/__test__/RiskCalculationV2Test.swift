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
//		let testCase = try XCTUnwrap(testCases[3])

			// WHEN
			let riskCalculation = RiskCalculationV2()
			let result = try riskCalculation.calculateRisk(
				exposureWindows: testCase.exposureWindows,
				configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
			)

			// THEN
//			print("Running Test: \(testCase.testCaseDescription)")
			XCTAssert(Calendar.current.isDate(result.detectionDate, inSameDayAs: Date()))

			XCTAssertEqual(result.riskLevel, testCase.expTotalRiskLevel.eitherLowOrIncreasedRiskLevel)

			XCTAssertEqual(result.minimumDistinctEncountersWithLowRisk, testCase.expTotalMinimumDistinctEncountersWithLowRisk)
			XCTAssertEqual(result.minimumDistinctEncountersWithHighRisk, testCase.expTotalMinimumDistinctEncountersWithHighRisk)

			XCTAssertEqual(result.ageInDaysOfMostRecentDateWithLowRisk, testCase.expAgeOfMostRecentDateWithLowRisk)
			XCTAssertEqual(result.ageInDaysOfMostRecentDateWithHighRisk, testCase.expAgeOfMostRecentDateWithHighRisk)

			// test only made if values in test cases are != nil
			if let expNumberOfExposureWindowsWithLowRisk = testCase.expNumberOfExposureWindowsWithLowRisk {
				XCTAssertEqual(result.numberOfExposureWindowsWithLowRisk, expNumberOfExposureWindowsWithLowRisk)
			}

			if let expNumberOfExposureWindowsWithHighRisk = testCase.expNumberOfExposureWindowsWithHighRisk {
				XCTAssertEqual(result.numberOfExposureWindowsWithHighRisk, expNumberOfExposureWindowsWithHighRisk)
			}

		}
	}

	lazy var testCasesWithConfiguration: TestCasesWithConfiguration = {
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


	func testGIVEN_dropExposureWindow_WHEN_riscCalculation_THEN_lowRisk() {
		// GIVEN "description": "drop Exposure Windows that do not match minutesAtAttenuationFilters (< 10 minutes)"

		let jsonData = """
		{
		  "ageInDays": 1,
		  "reportType": 2,
		  "infectiousness": 2,
		  "calibrationConfidence": 0,
		  "scanInstances": [
			{
			  "typicalAttenuation": 30,
			  "minAttenuation": 25,
			  "secondsSinceLastScan": 300
			},
			{
			  "typicalAttenuation": 30,
			  "minAttenuation": 25,
			  "secondsSinceLastScan": 299
			}
		  ]
		}
		""".data(using: .utf8)!

		let expsureWindow = try? JSONDecoder().decode(ExposureWindow.self, from: XCTUnwrap(jsonData))

		let riskCalculation = RiskCalculationV2()
		// WHEN
		guard let result = try? riskCalculation.calculateRisk(
			exposureWindows: [XCTUnwrap(expsureWindow)],
			configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
		) else {
			XCTFail("rik calulation failed")
			fatalError("calculation failed")
		}

		// THEN
		//		"expTotalRiskLevel": 1 -> hier wird eigentlich 0 oder 1_000 erwartet - der risk level mix ist hier das erste Problem ?
		XCTAssertEqual(result.riskLevel, EitherLowOrIncreasedRiskLevel.low)
		//		"expTotalMinimumDistinctEncountersWithLowRisk": 0,
		XCTAssertEqual(result.minimumDistinctEncountersWithLowRisk, 0)
		//		"expTotalMinimumDistinctEncountersWithHighRisk": 0
		XCTAssertEqual(result.minimumDistinctEncountersWithHighRisk, 0)
		//		"expAgeOfMostRecentDateWithLowRisk": null,
		XCTAssertEqual(result.ageInDaysOfMostRecentDateWithLowRisk, nil)
		//		"expAgeOfMostRecentDateWithHighRisk": null
		XCTAssertEqual(result.ageInDaysOfMostRecentDateWithHighRisk, nil)

	}

}
