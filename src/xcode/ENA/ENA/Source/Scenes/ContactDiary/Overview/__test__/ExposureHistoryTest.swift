////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class ExposureHistoryTest: XCTestCase {

	func testGIVEN_OneExposureHistoryPerDayAdded_WHEN_getDays_THEN_exposureHistoryIsCorrect() throws {
		// GIVEN
		let store = MockDiaryStore()
		store.addRiskLevelPerDate([
			try XCTUnwrap(dateFormatter.date(from: "2021-01-18")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-15")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-14")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-13")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-12")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-11")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-10")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-09")): RiskLevel.low
		])

		// WHEN
		let diaryDays = store.diaryDaysPublisher.value

		// THEN
		XCTAssertEqual(diaryDays[0].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[1].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[2].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[3].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[4].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[5].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[6].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[7].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[8].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[9].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[10].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[11].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[12].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[13].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[14].exposureEncounter, .none)
	}

	func testGIVEN_updateExposuresOnSomeDays_WHEN_getDays_THEN_HighRiskExposuresWillWin() throws {
		// GIVEN
		let store = MockDiaryStore()
		store.addRiskLevelPerDate([
			try XCTUnwrap(dateFormatter.date(from: "2021-01-18")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-15")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-14")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-13")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-12")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-11")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-10")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-09")): RiskLevel.low
		])

		store.addRiskLevelPerDate([
			try XCTUnwrap(dateFormatter.date(from: "2021-01-18")): RiskLevel.low,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-15")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-14")): RiskLevel.high,
			try XCTUnwrap(dateFormatter.date(from: "2021-01-09")): RiskLevel.low
		])

		// WHEN
		let diaryDays = store.diaryDaysPublisher.value

		// THEN
		XCTAssertEqual(diaryDays[0].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[1].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[2].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[3].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[4].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[5].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[6].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[7].exposureEncounter, .encounter(.high))
		XCTAssertEqual(diaryDays[8].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[9].exposureEncounter, .encounter(.low))
		XCTAssertEqual(diaryDays[10].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[11].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[12].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[13].exposureEncounter, .none)
		XCTAssertEqual(diaryDays[14].exposureEncounter, .none)
	}

	// MARK: - Private Helpers

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

}
