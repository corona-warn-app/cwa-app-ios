////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RiskCalculationResultTests: XCTestCase {

	/**
	{"calculationDate":632748771.53385794,"numberOfDaysWithHighRisk":0,"minimumDistinctEncountersWithLowRisk":0,"numberOfDaysWithLowRisk":0,"riskLevel":1,"minimumDistinctEncountersWithHighRisk":0}
	*/

	func testGIVEN_Version111JsonFormat_WHEN_ParserJson_THEN_ModelGetsCreated() throws {
		// GIVEN
		let testData =
			"{\"calculationDate\":632748771.53385794,\"numberOfDaysWithHighRisk\":0,\"minimumDistinctEncountersWithLowRisk\":0,\"numberOfDaysWithLowRisk\":0,\"riskLevel\":1,\"minimumDistinctEncountersWithHighRisk\":0}".data(using: .utf8)

		// WHEN

//		do {
			let model = try? JSONDecoder().decode(RiskCalculationResult.self, from: XCTUnwrap(testData))
			XCTAssertNotNil(model)
//		}
//
//		catch DecodingError.keyNotFound(let key, let context) {
//			print("missing key: \(key)")
//			print("Debug Description: \(context.debugDescription)")
//		}
//
//		catch DecodingError.valueNotFound(let type, let context) {
//			print("Type not found \(type)")
//			print("Debug Description: \(context.debugDescription)")
//		}
//
//		catch DecodingError.typeMismatch(let type, let context) {
//			print("Type mismatch found \(type)")
//			print("Debug Description: \(context.debugDescription)")
//		}
//
//		catch DecodingError.dataCorrupted(let context) {
//			print("Debug Description: \(context.debugDescription)")
//		}
//
//		catch {
//			fatalError("Failed to parse JSON answer")
//		}

		// THEN
	}

}
