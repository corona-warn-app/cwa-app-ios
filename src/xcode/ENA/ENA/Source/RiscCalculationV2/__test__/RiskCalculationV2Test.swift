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

	func testWHEN_loadJsonTestFile_THEN_testCasesWithConfigurationAreGreaterThanZero() {
		// WHEN

		// THEN
		XCTAssertGreaterThan(testCasesWithConfiguration.testCases.count, 0, "not tests found")
	}

	lazy var testCasesWithConfiguration: TestCasesWithConfiguration = {
		let testBundle = Bundle(for: RiscCalculationV2Test.self)
		guard let urlJsonFile = testBundle.url(forResource: "exposure-windows-risk-calculation", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			XCTFail("Failed init json file for tests")
			fatalError("Failed init json file for tests - stop hete")
		}

		do {
			return try JSONDecoder().decode(TestCasesWithConfiguration.self, from: data)
		} catch let DecodingError.keyNotFound(jsonKey, context) {
			Log.error("missing key: \(jsonKey)")
			Log.error("Debug Description: \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			Log.error("Type not found \(type)")
			Log.error("Debug Description: \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(type, context) {
			Log.error("Type mismatch found \(type)")
			Log.error("Debug Description: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			Log.error("Debug Description: \(context.debugDescription)")
		} catch {
			fatalError("Failed to parse JSON answer")
		}
		return TestCasesWithConfiguration()
	}()

}
