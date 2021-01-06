//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
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

    func testUpTo21DaysAgoNotSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .upTo21DaysAgo(Date(timeIntervalSinceReferenceDate: 0)),
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

    func testUpTo21DaysAgoSelected() {
		let viewModel = DatePickerDayViewModel(
			datePickerDay: .upTo21DaysAgo(Date(timeIntervalSinceReferenceDate: 0)),
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

	func testMoreThan21DaysAgoNotSelected() {
	 let viewModel = DatePickerDayViewModel(
		 datePickerDay: .moreThan21DaysAgo(Date(timeIntervalSinceReferenceDate: 0)),
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

		wait(for: [expectation], timeout: .medium)
	}

	func testTapOnMoreThan21DaysAgoDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate not called")
		expectation.isInverted = true

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .moreThan21DaysAgo(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: .medium)
	}

    func testTapOnUpTo21DaysAgoDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate called")

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .upTo21DaysAgo(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: .medium)
	}

    func testTapOnTodayDate() {
		let expectation = XCTestExpectation(description: "onTapOnDate called")

		let viewModel = DatePickerDayViewModel(
			datePickerDay: .today(Date(timeIntervalSinceReferenceDate: 0)),
			onTapOnDate: { _ in expectation.fulfill() },
			isSelected: false
		)

		viewModel.onTap()

		wait(for: [expectation], timeout: .medium)
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
