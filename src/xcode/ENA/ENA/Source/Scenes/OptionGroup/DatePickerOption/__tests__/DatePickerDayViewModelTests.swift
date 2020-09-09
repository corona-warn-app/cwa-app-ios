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

class DatePickerDayViewModelTests: XCTestCase {

    func testTodayNotSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		XCTAssertEqual(viewModel.fontSize, 16)
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textTint))
		XCTAssertEqual(viewModel.fontWeight, "bold")
		XCTAssertEqual(viewModel.accessibilityTraits, [.button])

		XCTAssertEqual(viewModel.dayString, "1")
		XCTAssertEqual(viewModel.accessibilityLabel, "1. Januar 2001")
		XCTAssertTrue(viewModel.isSelectable)
    }

    func testTodaySelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: true
		)

		XCTAssertTrue(viewModel.isSelected)

		XCTAssertEqual(viewModel.fontSize, 16)
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .tint))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.fontWeight, "bold")
		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])

		XCTAssertEqual(viewModel.dayString, "1")
		XCTAssertEqual(viewModel.accessibilityLabel, "1. Januar 2001")
		XCTAssertTrue(viewModel.isSelectable)
    }

    func testPastNotSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .past(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		XCTAssertEqual(viewModel.fontSize, 16)
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textPrimary1))
		XCTAssertEqual(viewModel.fontWeight, "regular")
		XCTAssertEqual(viewModel.accessibilityTraits, [.button])

		XCTAssertEqual(viewModel.dayString, "1")
		XCTAssertEqual(viewModel.accessibilityLabel, "1. Januar 2001")
		XCTAssertTrue(viewModel.isSelectable)
    }

    func testPastSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .past(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: true
		)

		XCTAssertTrue(viewModel.isSelected)

		XCTAssertEqual(viewModel.fontSize, 16)
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .tint))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.fontWeight, "medium")
		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])

		XCTAssertEqual(viewModel.dayString, "1")
		XCTAssertEqual(viewModel.accessibilityLabel, "1. Januar 2001")
		XCTAssertTrue(viewModel.isSelectable)
    }

    func testFutureNotSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .future(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		XCTAssertEqual(viewModel.fontSize, 16)
		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textPrimary3))
		XCTAssertEqual(viewModel.fontWeight, "regular")
		XCTAssertEqual(viewModel.accessibilityTraits, [])

		XCTAssertEqual(viewModel.dayString, "1")
		XCTAssertEqual(viewModel.accessibilityLabel, "1. Januar 2001")
		XCTAssertFalse(viewModel.isSelectable)
    }

    func testTapOnFutureDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate not called")
		expectation.isInverted = true

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .future(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: 1.0)
	}

    func testTapOnPastDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate called")

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .past(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: 1.0)
	}

    func testTapOnTodayDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate called")

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: 1.0)
	}

    func testChangeTodayFromNotSelectedToSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		viewModel.isSelected = true

		XCTAssertTrue(viewModel.isSelected)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .tint))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textContrast))
		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])
    }

    func testChangeTodayFromSelectedToNotSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: true
		)

		XCTAssertTrue(viewModel.isSelected)

		viewModel.isSelected = false

		XCTAssertFalse(viewModel.isSelected)

		XCTAssertEqual(viewModel.backgroundColor, .enaColor(for: .background))
		XCTAssertEqual(viewModel.textColor, .enaColor(for: .textTint))
		XCTAssertEqual(viewModel.accessibilityTraits, [.button])
    }

    func testSelectIfSameDateWithSameDate() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		viewModel.selectIfSameDate(date: Date(timeIntervalSinceReferenceDate: 0))

		XCTAssertTrue(viewModel.isSelected)
    }

    func testSelectIfSameDateWithDifferentDate() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in },
			isSelected: false
		)

		XCTAssertFalse(viewModel.isSelected)

		viewModel.selectIfSameDate(date: Date(timeIntervalSinceReferenceDate: 24 * 60 * 60))

		XCTAssertFalse(viewModel.isSelected)
    }

}
