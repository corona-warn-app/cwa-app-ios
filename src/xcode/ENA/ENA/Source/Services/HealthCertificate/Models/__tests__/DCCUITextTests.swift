//
// 🦠 Corona-Warn-App
//

import XCTest
import AnyCodable
@testable import ENA

class DCCUITextTests: XCTestCase {

	func testWHEN_LoadingJsonTestFile_THEN_AllTestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = testCasesWithCCLConfiguration.testCases

		// THEN
		XCTAssertEqual(testCases.count, 17)
	}
	
	func testGIVEN_TestCases_WHEN_LocalizeStringForEachTestCase_THEN_ResultIsCorrect() {
		// GIVEN
		let testCases = testCasesWithCCLConfiguration.testCases

		for testCase in testCases {
			let dccUIText = testCase.textDescriptor
			
			XCTAssertEqual(dccUIText.localized(), testCase.assertions[0].text)
			
			// DCCUIText.fake(type: testCase.textDescriptor.type, quantity: testCase.textDescriptor.quantity, quantityParameterIndex: testCase.textDescriptor.quantityParameterIndex, functionName: testCase.textDescriptor.functionName, localizedText: testCase.textDescriptor.localizedText, parameters: testCase.textDescriptor.parameters)
		}
	}
	
	// MARK: - Private

	private lazy var testCasesWithCCLConfiguration: TestCasesWithCCLConfiguration = {
		let testBundle = Bundle(for: DCCUITextTests.self)
		guard let urlJsonFile = testBundle.url(forResource: "ccl-text-descriptor-test-cases", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			fatalError("Failed init json file for tests - stop here")
		}

		do {
			return try JSONDecoder().decode(TestCasesWithCCLConfiguration.self, from: data)
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
