//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SystemTimeTests: XCTestCase {
	
	func test_TimeStrings_WithoutDayChangeDueTimezone() throws {
		let localDateFormatter = SystemTime.localDateFormatter
		localDateFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		let localDateTimeFormatter = SystemTime.localDateTimeFormatter
		localDateTimeFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		let localDateMidnightTimeFormatter = SystemTime.localDateMidnightTimeFormatter
		localDateMidnightTimeFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		
		let dateString = "2022-01-28T15:30:00+01:00"
		let date = try XCTUnwrap(SystemTime.localDateTimeFormatter.date(from: dateString))
		
		let localDate = localDateFormatter.string(from: date)
		let localDateTime = localDateTimeFormatter.string(from: date)
		let localDateTimeMidnight = localDateMidnightTimeFormatter.string(from: date)
		let utcDate = SystemTime.utcDateFormatter.string(from: date)
		let utcDateTime = SystemTime.utcDateTimeFormatter.string(from: date)
		let utcDateTimeMidnight = SystemTime.utcDateTimeMidnightFormatter.string(from: date)
		
		XCTAssertEqual(localDate, "2022-01-28")
		XCTAssertEqual(localDateTime, "2022-01-28T15:30:00+01:00")
		XCTAssertEqual(localDateTimeMidnight, "2022-01-28T00:00:00+01:00")
		XCTAssertEqual(utcDate, "2022-01-28")
		XCTAssertEqual(utcDateTime, "2022-01-28T14:30:00Z")
		XCTAssertEqual(utcDateTimeMidnight, "2022-01-28T00:00:00Z")
	}
	
	func test_TimeStrings_WithDayChangeDueTimezone() throws {
		let localDateFormatter = SystemTime.localDateFormatter
		localDateFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		let localDateTimeFormatter = SystemTime.localDateTimeFormatter
		localDateTimeFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		let localDateMidnightTimeFormatter = SystemTime.localDateMidnightTimeFormatter
		localDateMidnightTimeFormatter.timeZone = try XCTUnwrap(TimeZone(abbreviation: "CET"))
		
		let dateString = "2022-01-28T00:30:00+01:00"
		let date = try XCTUnwrap(SystemTime.localDateTimeFormatter.date(from: dateString))
		
		let localDate = localDateFormatter.string(from: date)
		let localDateTime = localDateTimeFormatter.string(from: date)
		let localDateTimeMidnight = localDateMidnightTimeFormatter.string(from: date)
		let utcDate = SystemTime.utcDateFormatter.string(from: date)
		let utcDateTime = SystemTime.utcDateTimeFormatter.string(from: date)
		let utcDateTimeMidnight = SystemTime.utcDateTimeMidnightFormatter.string(from: date)

		XCTAssertEqual(localDate, "2022-01-28")
		XCTAssertEqual(localDateTime, "2022-01-28T00:30:00+01:00")
		XCTAssertEqual(localDateTimeMidnight, "2022-01-28T00:00:00+01:00")
		XCTAssertEqual(utcDate, "2022-01-27")
		XCTAssertEqual(utcDateTime, "2022-01-27T23:30:00Z")
		XCTAssertEqual(utcDateTimeMidnight, "2022-01-27T00:00:00Z")
	}
}
