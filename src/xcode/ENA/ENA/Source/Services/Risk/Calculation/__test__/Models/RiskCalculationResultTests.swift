////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskCalculationResultTests: XCTestCase {

	/*** init a new model all values get stored as expected*/
	func testGIVEN_InitRiskCalculationResult_THEN_AllValuesGetStored() {
	// GIVEN
		let today = Date()
	let riskCalculationResult = RiskCalculationResult(
		riskLevel: .low,
		minimumDistinctEncountersWithLowRisk: 0,
		minimumDistinctEncountersWithHighRisk: 5,
		mostRecentDateWithLowRisk: today,
		mostRecentDateWithHighRisk: today,
		numberOfDaysWithLowRisk: 10,
		numberOfDaysWithHighRisk: 3,
		calculationDate: today,
		riskLevelPerDate: [today: .high]
	)

	// THEN
		XCTAssertEqual(riskCalculationResult.riskLevel, .low)
		XCTAssertEqual(riskCalculationResult.minimumDistinctEncountersWithLowRisk, 0)
		XCTAssertEqual(riskCalculationResult.minimumDistinctEncountersWithHighRisk, 5)
		XCTAssertEqual(riskCalculationResult.mostRecentDateWithLowRisk, today)
		XCTAssertEqual(riskCalculationResult.mostRecentDateWithHighRisk, today)
		XCTAssertEqual(riskCalculationResult.numberOfDaysWithLowRisk, 10)
		XCTAssertEqual(riskCalculationResult.numberOfDaysWithHighRisk, 3)
		XCTAssertEqual(riskCalculationResult.calculationDate, today)
		XCTAssertEqual(riskCalculationResult.riskLevelPerDate, [today: .high])
	}


	/*** new json format with empty 'riskLevelPerDate' should init without problems */
	func testGIVEN_NewFormatRiskCalculationResultWithoutRiskLevelPerDay_WHEN_ParseJson_THEN_RiskCalculationResultGetsCreated() throws {
		// GIVEN
		let newFormattedData = """
			{
			"minimumDistinctEncountersWithHighRisk": 0,
			"riskLevelPerDate": [],
			"numberOfDaysWithLowRisk": 0,
			"calculationDate": 632684966.219077,
			"numberOfDaysWithHighRisk": 0,
			"minimumDistinctEncountersWithLowRisk": 0,
			"riskLevel": 1
			}
			"""
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(newFormattedData))

		// THEN
		XCTAssertEqual(riskCalculationResult.riskLevelPerDate.count, 0)
	}

	/*** new json format with given 'riskLevelPerDate' should init without problems */
	func testGIVEN_NewFormatRiskCalculationResultWithThreeRiskLevelPerDay_WHEN_ParseJson_THEN_RiskCalculationResultGetsCreated() throws {
		// GIVEN
		let newFormattedData = """
			{
			"minimumDistinctEncountersWithHighRisk": 0,
			"mostRecentDateWithLowRisk": 632530800,
			"riskLevelPerDate": [
				632530800,
				1,
				632444400,
				1,
				632358000,
				1
			],
			"numberOfDaysWithLowRisk": 3,
			"calculationDate": 632756849.536073,
			"numberOfDaysWithHighRisk": 0,
			"minimumDistinctEncountersWithLowRisk": 3,
			"riskLevel": 1
			}
			"""
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(newFormattedData))

		// THEN
		XCTAssertEqual(riskCalculationResult.riskLevelPerDate.count, 3)
		XCTAssertEqual(riskCalculationResult.minimumDistinctEncountersWithLowRisk, 3)
		XCTAssertEqual(riskCalculationResult.minimumDistinctEncountersWithHighRisk, 0)
	}

	/*** 'old' json format without 'riskLevelPerDate' should init without problems */
	func testGIVEN_OldFormattedData_WHEN_ParseJson_THEN_RiskCalculationResultModelGetsCreated() throws {
		// GIVEN
		let oldFormattedData = """
			{
			"calculationDate": 632748771.533858,
			"numberOfDaysWithHighRisk": 0,
			"minimumDistinctEncountersWithLowRisk": 0,
			"numberOfDaysWithLowRisk": 0,
			"riskLevel": 1,
			"minimumDistinctEncountersWithHighRisk": 0
			}
			"""
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(oldFormattedData))

		// THEN
		XCTAssertEqual(riskCalculationResult.riskLevelPerDate.count, 0)
	}

}
