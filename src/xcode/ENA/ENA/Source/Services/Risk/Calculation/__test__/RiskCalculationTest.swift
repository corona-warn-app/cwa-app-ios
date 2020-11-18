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

import XCTest
@testable import ENA

class RiskCalculationTest: XCTestCase {

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
			let result = try RiskCalculation().calculateRisk(
				exposureWindows: testCase.exposureWindows,
				configuration: testCasesWithConfiguration.defaultRiskCalculationConfiguration
			)

			// THEN
			XCTAssert(Calendar.current.isDate(result.calculationDate, inSameDayAs: Date()))

			XCTAssertEqual(result.riskLevel, testCase.expTotalRiskLevel)

			XCTAssertEqual(result.minimumDistinctEncountersWithLowRisk, testCase.expTotalMinimumDistinctEncountersWithLowRisk)
			XCTAssertEqual(result.minimumDistinctEncountersWithHighRisk, testCase.expTotalMinimumDistinctEncountersWithHighRisk)

			XCTAssertEqual(result.mostRecentDateWithLowRisk?.ageInDays, testCase.expAgeOfMostRecentDateWithLowRisk)
			XCTAssertEqual(result.mostRecentDateWithHighRisk?.ageInDays, testCase.expAgeOfMostRecentDateWithHighRisk)

			XCTAssertEqual(result.numberOfDaysWithLowRisk, testCase.expNumberOfDaysWithLowRisk)
			XCTAssertEqual(result.numberOfDaysWithHighRisk, testCase.expNumberOfDaysWithHighRisk)
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
