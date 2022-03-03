////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestResultTests: CWATestCase {

	func testOnlyResultsForCorrectTypeAreAccepted() {
		XCTAssertEqual(TestResult(serverResponse: 0, coronaTestType: .pcr), .pending)
		XCTAssertEqual(TestResult(serverResponse: 0, coronaTestType: .antigen), .pending)

		XCTAssertEqual(TestResult(serverResponse: 1, coronaTestType: .pcr), .negative)
		XCTAssertEqual(TestResult(serverResponse: 1, coronaTestType: .antigen), .invalid)

		XCTAssertEqual(TestResult(serverResponse: 2, coronaTestType: .pcr), .positive)
		XCTAssertEqual(TestResult(serverResponse: 2, coronaTestType: .antigen), .invalid)

		XCTAssertEqual(TestResult(serverResponse: 3, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 3, coronaTestType: .antigen), .invalid)

		XCTAssertEqual(TestResult(serverResponse: 4, coronaTestType: .pcr), .expired)
		XCTAssertEqual(TestResult(serverResponse: 4, coronaTestType: .antigen), .invalid)

		XCTAssertEqual(TestResult(serverResponse: 5, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 5, coronaTestType: .antigen), .pending)

		XCTAssertEqual(TestResult(serverResponse: 6, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 6, coronaTestType: .antigen), .negative)

		XCTAssertEqual(TestResult(serverResponse: 7, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 7, coronaTestType: .antigen), .positive)

		XCTAssertEqual(TestResult(serverResponse: 8, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 8, coronaTestType: .antigen), .invalid)

		XCTAssertEqual(TestResult(serverResponse: 9, coronaTestType: .pcr), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 9, coronaTestType: .antigen), .expired)
	}

	func testServerResponse() {
		XCTAssertEqual(TestResult.serverResponse(for: .pending, on: .pcr), 0)
		XCTAssertEqual(TestResult.serverResponse(for: .negative, on: .pcr), 1)
		XCTAssertEqual(TestResult.serverResponse(for: .positive, on: .pcr), 2)
		XCTAssertEqual(TestResult.serverResponse(for: .invalid, on: .pcr), 3)
		XCTAssertEqual(TestResult.serverResponse(for: .expired, on: .pcr), 4)
		XCTAssertEqual(TestResult.serverResponse(for: .pending, on: .antigen), 5)
		XCTAssertEqual(TestResult.serverResponse(for: .negative, on: .antigen), 6)
		XCTAssertEqual(TestResult.serverResponse(for: .positive, on: .antigen), 7)
		XCTAssertEqual(TestResult.serverResponse(for: .invalid, on: .antigen), 8)
		XCTAssertEqual(TestResult.serverResponse(for: .expired, on: .antigen), 9)
	}

}
