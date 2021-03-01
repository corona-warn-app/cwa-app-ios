//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskCalculationTest: XCTestCase {

	func testWHEN_LoadingJsonTestFile_THEN_24TestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = testCasesWithConfiguration.testCases

		// THEN
		XCTAssertEqual(testCases.count, 28)
	}

	func testGIVEN_TestCases_WHEN_CalculatingRiskForEachTestCase_THEN_ResultIsCorrect() {
		// GIVEN
		let testCases = testCasesWithConfiguration.testCases

		for testCase in testCases {
			// WHEN
			let result = RiskCalculation().calculateRisk(
				exposureWindows: testCase.exposureWindows,
				configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
			)

			// THEN
			XCTAssertTrue(Calendar.current.isDate(result.calculationDate, inSameDayAs: Date()))

			XCTAssertEqual(result.riskLevel, testCase.expTotalRiskLevel)

			XCTAssertEqual(result.minimumDistinctEncountersWithLowRisk, testCase.expTotalMinimumDistinctEncountersWithLowRisk)
			XCTAssertEqual(result.minimumDistinctEncountersWithHighRisk, testCase.expTotalMinimumDistinctEncountersWithHighRisk)

			XCTAssertEqual(result.mostRecentDateWithLowRisk?.ageInDays, testCase.expAgeOfMostRecentDateWithLowRisk)
			XCTAssertEqual(result.mostRecentDateWithHighRisk?.ageInDays, testCase.expAgeOfMostRecentDateWithHighRisk)

			XCTAssertEqual(result.numberOfDaysWithLowRisk, testCase.expNumberOfDaysWithLowRisk)
			XCTAssertEqual(result.numberOfDaysWithHighRisk, testCase.expNumberOfDaysWithHighRisk)

			switch result.riskLevel {
			case .low:
				XCTAssertEqual(result.minimumDistinctEncountersWithCurrentRiskLevel, result.minimumDistinctEncountersWithLowRisk)
				XCTAssertEqual(result.mostRecentDateWithCurrentRiskLevel, result.mostRecentDateWithLowRisk)
				XCTAssertEqual(result.numberOfDaysWithCurrentRiskLevel, result.numberOfDaysWithLowRisk)
			case .high:
				XCTAssertEqual(result.minimumDistinctEncountersWithCurrentRiskLevel, result.minimumDistinctEncountersWithHighRisk)
				XCTAssertEqual(result.mostRecentDateWithCurrentRiskLevel, result.mostRecentDateWithHighRisk)
				XCTAssertEqual(result.numberOfDaysWithCurrentRiskLevel, result.numberOfDaysWithHighRisk)
			}
		}
	}

	// MARK: - Private

	private lazy var testCasesWithConfiguration: TestCasesWithConfiguration = {
		let testBundle = Bundle(for: RiskCalculationTest.self)
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
