////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestResultTests: XCTestCase {

	func test_when_TestResultInitilized_Then_ModuloWorksAsExpected() {
		XCTAssertEqual(TestResult(serverResponse: 0), .pending)
		XCTAssertEqual(TestResult(serverResponse: 1), .negative)
		XCTAssertEqual(TestResult(serverResponse: 2), .positive)
		XCTAssertEqual(TestResult(serverResponse: 3), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 4), .expired)
		XCTAssertEqual(TestResult(serverResponse: 5), .pending)
		XCTAssertEqual(TestResult(serverResponse: 6), .negative)
		XCTAssertEqual(TestResult(serverResponse: 7), .positive)
		XCTAssertEqual(TestResult(serverResponse: 8), .invalid)
		XCTAssertEqual(TestResult(serverResponse: 9), .expired)
	}

}
