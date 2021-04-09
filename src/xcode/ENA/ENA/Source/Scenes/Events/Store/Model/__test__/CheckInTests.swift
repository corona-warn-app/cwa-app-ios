//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckInTests: XCTestCase {

	func testWHEN_LoadingJsonTestFile_THEN_AllTestCasesWithConfigurationAreReturned() {
		// WHEN
		let testCases = testCasesWithConfiguration.testCases

		// THEN
		XCTAssertEqual(testCases.count, 10)
	}

	func testGIVEN_TestCases_WHEN_DerivingWarningTimeInterval_THEN_ResultIsCorrect() {
		// GIVEN
		let testCases = testCasesWithConfiguration.testCases

		for testCase in testCases {
			// WHEN
			let checkin = Checkin.mock(
				checkinStartDate: testCase.startDate,
				checkinEndDate: testCase.endDate
			)

			let derivedCheckin = checkin.derivingWarningTimeInterval(config: testCasesWithConfiguration.defaultConfiguration)

			// THEN
			XCTAssertEqual(derivedCheckin?.checkinStartDate, testCase.expStartDate)
			XCTAssertEqual(derivedCheckin?.checkinEndDate, testCase.expEndDate)
		}
	}

	// MARK: - Private

	private lazy var testCasesWithConfiguration: CheckinTestCasesWithConfiguration = {
		let testBundle = Bundle(for: CheckinTests.self)
		guard let urlJsonFile = testBundle.url(forResource: "checkin-timeinterval-derivation", withExtension: "json"),
			  let data = try? Data(contentsOf: urlJsonFile) else {
			fatalError("Failed init json file for tests - stop here")
		}

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmXXXXX"

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(dateFormatter)

		do {
			return try decoder.decode(CheckinTestCasesWithConfiguration.self, from: data)
		} catch let DecodingError.keyNotFound(jsonKey, context) {
			fatalError("missing key: \(jsonKey)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.valueNotFound(type, context) {
			fatalError("Type not found \(type)\nDebug Description: \(context.debugDescription)")
		} catch let DecodingError.typeMismatch(type, context) {
			fatalError("Type mismatch found \(type)\nDebug Description: \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(let context) {
			fatalError("Debug Description: \(context.debugDescription) \(context)")
		} catch {
			fatalError("Failed to parse JSON answer")
		}
	}()

}
