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

import XCTest
import Combine
@testable import ENA

class DatePickerOptionViewModelTests: XCTestCase {

    func testMonthAndYearChange() {
		let viewModel = DatePickerOptionViewModel(
			today: Date(timeIntervalSinceReferenceDate: 0)
		)

		XCTAssertEqual(viewModel.subtitle, "Dezember 2000 – Januar 2001")

		XCTAssertEqual(viewModel.datePickerDays.count, 28)
		XCTAssertEqual(viewModel.datePickerDays[0], .past(Date(timeIntervalSinceReferenceDate: -21 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[1], .past(Date(timeIntervalSinceReferenceDate: -20 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[2], .past(Date(timeIntervalSinceReferenceDate: -19 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[3], .past(Date(timeIntervalSinceReferenceDate: -18 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[4], .past(Date(timeIntervalSinceReferenceDate: -17 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[5], .past(Date(timeIntervalSinceReferenceDate: -16 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[6], .past(Date(timeIntervalSinceReferenceDate: -15 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[7], .past(Date(timeIntervalSinceReferenceDate: -14 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[8], .past(Date(timeIntervalSinceReferenceDate: -13 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[9], .past(Date(timeIntervalSinceReferenceDate: -12 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[10], .past(Date(timeIntervalSinceReferenceDate: -11 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[11], .past(Date(timeIntervalSinceReferenceDate: -10 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[12], .past(Date(timeIntervalSinceReferenceDate: -9 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[13], .past(Date(timeIntervalSinceReferenceDate: -8 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[14], .past(Date(timeIntervalSinceReferenceDate: -7 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[15], .past(Date(timeIntervalSinceReferenceDate: -6 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[16], .past(Date(timeIntervalSinceReferenceDate: -5 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[17], .past(Date(timeIntervalSinceReferenceDate: -4 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[18], .past(Date(timeIntervalSinceReferenceDate: -3 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[19], .past(Date(timeIntervalSinceReferenceDate: -2 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[20], .past(Date(timeIntervalSinceReferenceDate: -1 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[21], .today(Date(timeIntervalSinceReferenceDate: 0)))
		XCTAssertEqual(viewModel.datePickerDays[22], .future(Date(timeIntervalSinceReferenceDate: +1 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[23], .future(Date(timeIntervalSinceReferenceDate: +2 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[24], .future(Date(timeIntervalSinceReferenceDate: +3 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[25], .future(Date(timeIntervalSinceReferenceDate: +4 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[26], .future(Date(timeIntervalSinceReferenceDate: +5 * 24 * 60 * 60)))
		XCTAssertEqual(viewModel.datePickerDays[27], .future(Date(timeIntervalSinceReferenceDate: +6 * 24 * 60 * 60)))

		XCTAssertEqual(viewModel.weekdays.count, 7)
		XCTAssertEqual(viewModel.weekdays, ["M", "D", "M", "D", "F", "S", "S"])

		XCTAssertEqual(viewModel.weekdayTextColors.count, 7)
		XCTAssertEqual(viewModel.weekdayTextColors, [
			.enaColor(for: .tint),
			.enaColor(for: .textPrimary2),
			.enaColor(for: .textPrimary2),
			.enaColor(for: .textPrimary2),
			.enaColor(for: .textPrimary2),
			.enaColor(for: .textPrimary2),
			.enaColor(for: .textPrimary2)
		])
    }

	func testMonthChange() {
		let viewModel = DatePickerOptionViewModel(
			today: Date(timeIntervalSinceReferenceDate: 31 * 24 * 60 * 60)
		)

		XCTAssertEqual(viewModel.subtitle, "Januar–Februar 2001")
	}

	func testWithinOneMonth() {
		let viewModel = DatePickerOptionViewModel(
			today: Date(timeIntervalSinceReferenceDate: 28 * 24 * 60 * 60)
		)

		XCTAssertEqual(viewModel.subtitle, "Januar 2001")
	}

	func test() {
		let viewModel = DatePickerOptionViewModel(
			today: Date(timeIntervalSinceReferenceDate: 28 * 24 * 60 * 60),
			calendar: .gregorian(with: .init(identifier: "en-US"))
		)

		XCTAssertEqual(viewModel.weekdays.count, 7)
		XCTAssertEqual(viewModel.weekdays, ["S", "M", "D", "M", "D", "F", "S"])
	}

}
