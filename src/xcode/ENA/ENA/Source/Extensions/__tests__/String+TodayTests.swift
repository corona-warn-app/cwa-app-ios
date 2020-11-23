//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class StringTodayTests: XCTestCase {
	func testTodayFormat_Now() {
		let formatted = String.formattedToday()
		XCTAssertNotNil(formatted.range(of: #"\d{4}-\d{2}-\d{2}"#, options: .regularExpression), "Expected format to be in yyyy-MM-dd")
	}

	func testTodayFormat_SetDate() {
		let date = DateComponents(
			calendar: Calendar.current,
			timeZone: TimeZone(abbreviation: "UTC"),
			year: 2020,
			month: 6,
			day: 16,
			hour: 23,
			minute: 59,
			second: 59
		).date ?? .distantPast
		let formatter = DateFormatter.packagesDayDateFormatter

		XCTAssertEqual(formatter.string(from: date), "2020-06-16")
	}

	func testFormatterProperties() {
		let formatter = DateFormatter.packagesDayDateFormatter

		XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd")
		XCTAssertEqual(formatter.timeZone, TimeZone(abbreviation: "UTC"))
		XCTAssertEqual(formatter.locale, Locale(identifier: "en_US_POSIX"))
		XCTAssertEqual(formatter.calendar, Calendar(identifier: .gregorian))
	}
}
