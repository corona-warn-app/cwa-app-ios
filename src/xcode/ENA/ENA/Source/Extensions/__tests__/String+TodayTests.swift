//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
		let formatter = DateFormatter.packagesDateFormatter

		XCTAssertEqual(formatter.string(from: date), "2020-06-16")
	}

	func testFormatterProperties() {
		let formatter = DateFormatter.packagesDateFormatter

		XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd")
		XCTAssertEqual(formatter.timeZone, TimeZone(abbreviation: "UTC"))
		XCTAssertEqual(formatter.locale, Locale(identifier: "en_US_POSIX"))
		XCTAssertEqual(formatter.calendar, Calendar(identifier: .gregorian))
	}
}
