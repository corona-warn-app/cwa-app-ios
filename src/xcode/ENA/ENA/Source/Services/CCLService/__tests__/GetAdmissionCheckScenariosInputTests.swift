//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import AnyCodable
@testable import ENA

class GetAdmissionCheckScenariosInputTests: XCTestCase {
	
	func test_TimeStrings_WithoutDayChangeDueTimezone() throws {
		SystemTime.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		
		let dateString = "2022-01-28T15:30:00+01:00"
		let date = try XCTUnwrap(SystemTime.localDateTimeFormatter.date(from: dateString))
		
		let input = GetAdmissionCheckScenariosInput.make(with: date, language: "de")
		guard let systemTime: SystemTime = input["now"]?.value as? SystemTime else {
			XCTFail("Systemtime expected")
			return
		}
		
		XCTAssertEqual(systemTime.localDate, "2022-01-28")
		XCTAssertEqual(systemTime.localDateTime, "2022-01-28T15:30:00+01:00")
		XCTAssertEqual(systemTime.localDateTimeMidnight, "2022-01-28T00:00:00+01:00")
		XCTAssertEqual(systemTime.utcDate, "2022-01-28")
		XCTAssertEqual(systemTime.utcDateTime, "2022-01-28T14:30:00Z")
		XCTAssertEqual(systemTime.utcDateTimeMidnight, "2022-01-28T00:00:00Z")
	}
	
	func test_TimeStrings_WithDayChangeDueTimezone() throws {
		SystemTime.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))

		let dateString = "2022-01-28T00:30:00+01:00"
		let date = try XCTUnwrap(SystemTime.localDateTimeFormatter.date(from: dateString))
		
		let input = GetAdmissionCheckScenariosInput.make(with: date, language: "de")
		guard let systemTime: SystemTime = input["now"]?.value as? SystemTime else {
			XCTFail("Systemtime expected")
			return
		}
		
		XCTAssertEqual(systemTime.localDate, "2022-01-28")
		XCTAssertEqual(systemTime.localDateTime, "2022-01-28T00:30:00+01:00")
		XCTAssertEqual(systemTime.localDateTimeMidnight, "2022-01-28T00:00:00+01:00")
		XCTAssertEqual(systemTime.utcDate, "2022-01-27")
		XCTAssertEqual(systemTime.utcDateTime, "2022-01-27T23:30:00Z")
		XCTAssertEqual(systemTime.utcDateTimeMidnight, "2022-01-27T00:00:00Z")
	}
	
	func test_OtherData() throws {
		SystemTime.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))

		let input = GetAdmissionCheckScenariosInput.make(with: Date(), language: "de")
		
		XCTAssertEqual(input["os"], AnyDecodable("ios"))
		XCTAssertEqual(input["language"], AnyDecodable("de"))
		XCTAssertNotNil(input["now"])
	}
	
	// ⚠️⚠️⚠️ Please read this before adding tests here: For new tests involving GetAdmissionCheckScenariosInputTests, please set the timeZone of SystemTime to "CET". Otherwise all the tests in this test case will get flaky. This is because of the static dateformatters.
}
