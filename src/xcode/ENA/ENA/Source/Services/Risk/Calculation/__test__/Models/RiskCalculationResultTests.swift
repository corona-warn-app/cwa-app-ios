////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskCalculationResultTests: XCTestCase {

	func testGIVEN_NewFormatRiskCalculationResultWithoutRiskLeevlPerDay_WHEN_ParseJson_THEN_RiskCalculationResultGetsCreated() {
		// GIVEN
		let newFormattedData = "{\"minimumDistinctEncountersWithHighRisk\":0,\"riskLevelPerDate\":[],\"numberOfDaysWithLowRisk\":0,\"calculationDate\":632684966.21907699,\"numberOfDaysWithHighRisk\":0,\"minimumDistinctEncountersWithLowRisk\":0,\"riskLevel\":1}"
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try? JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(newFormattedData))

		// THEN
		XCTAssertNotNil(riskCalculationResult)
		XCTAssertEqual(riskCalculationResult?.riskLevelPerDate.count, 0)
	}

	func testGIVEN_NewFormatRiskCalculationResultWithThreeRiskLeevlPerDay_WHEN_ParseJson_THEN_RiskCalculationResultGetsCreated() {
		// GIVEN
		let newFormattedData = "{\"minimumDistinctEncountersWithHighRisk\":0,\"mostRecentDateWithLowRisk\":632530800,\"riskLevelPerDate\":[632530800,1,632444400,1,632358000,1],\"numberOfDaysWithLowRisk\":3,\"calculationDate\":632756849.53607297,\"numberOfDaysWithHighRisk\":0,\"minimumDistinctEncountersWithLowRisk\":3,\"riskLevel\":1}"
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try? JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(newFormattedData))

		// THEN
		XCTAssertNotNil(riskCalculationResult)
		XCTAssertEqual(riskCalculationResult?.riskLevelPerDate.count, 3)
	}

	func testGIVEN_OldFormattedData_WHEN_ParseJson_THEN_RiskCalculationResultModelGetsCreated() {
		// GIVEN
		let oldFormattedData =
			"{\"calculationDate\":632748771.53385794,\"numberOfDaysWithHighRisk\":0,\"minimumDistinctEncountersWithLowRisk\":0,\"numberOfDaysWithLowRisk\":0,\"riskLevel\":1,\"minimumDistinctEncountersWithHighRisk\":0}"
			.data(using: .utf8)

		// WHEN
		let riskCalculationResult = try? JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(oldFormattedData))

		// THEN
		XCTAssertNotNil(riskCalculationResult)
		XCTAssertEqual(riskCalculationResult?.riskLevelPerDate.count, 0)
	}

}
