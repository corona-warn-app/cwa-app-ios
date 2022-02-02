//
// 🦠 Corona-Warn-App
//

import XCTest
import AnyCodable
@testable import ENA

class DCCUITextTests: XCTestCase {

	func testWHEN_LoadingJsonTestFile_THEN_AllTestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = dccUITextTestCases.testCases

		// THEN
		XCTAssertEqual(testCases.count, 22)
	}
	
	
	func testGIVEN_TestCases_WHEN_LocalizeStringForEachTestCase_THEN_ResultIsCorrect() {
		// GIVEN
		let testCases = dccUITextTestCases.testCases
		let cclService = FakeCCLService()

		DCCUIText.localDateFormatter.timeZone = TimeZone(abbreviation: "GMT+1")
		DCCUIText.localDateTimeFormatter.timeZone = TimeZone(abbreviation: "GMT+1")
		
		for testCase in testCases {
			// WHEN
			let dccUIText = testCase.textDescriptor
			let expectationText = testCase.assertions[0].text
			
			// THEN
			XCTAssertEqual(dccUIText.localized(cclService: cclService), expectationText, "Failing Test: \(testCase.description)")
		}
	}
	
	// MARK: - Private

	private lazy var dccUITextTestCases: DCCUITextTestCases = {
		let testBundle = Bundle(for: DCCUITextTests.self)
		guard let urlJsonFile = testBundle.url(forResource: "ccl-text-descriptor-test-cases", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			fatalError("Failed init json file for tests - stop here")
		}

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		do {
			return try JSONDecoder().decode(DCCUITextTestCases.self, from: data)
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
