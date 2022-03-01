////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestResultTests: CWATestCase {

	func test_when_TestResultInitilized_Then_ModuloWorksAsExpected() {
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

}
