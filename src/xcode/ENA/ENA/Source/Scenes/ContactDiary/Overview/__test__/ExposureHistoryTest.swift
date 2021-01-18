////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class ExposureHistoryTest: XCTestCase {

	func testGIVEN_Store_WHEN_getDays_THEN_exposureHistoryIsCorrect() throws {
		// GIVEN
		let store = try makeMockStore()

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

	// MARK: - Private Helpers

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	private func makeMockStore() throws -> MockDiaryStore {
		let store = MockDiaryStore()
		store.addContactPerson(name: "Kai-Marcel Teuber")
		store.addLocation(name: "Dönerland")

		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-18")
		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-17")
		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-16")
		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-15")
		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-14")
		store.addContactPersonEncounter(contactPersonId: 0, date: "2021-01-13")

		store.addLocationVisit(locationId: 0, date: "2021-01-15")
		store.addLocationVisit(locationId: 0, date: "2021-01-14")
		store.addLocationVisit(locationId: 0, date: "2021-01-13")
		store.addLocationVisit(locationId: 0, date: "2021-01-12")
		store.addLocationVisit(locationId: 0, date: "2021-01-11")
		store.addLocationVisit(locationId: 0, date: "2021-01-10")

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
		return store
	}

}
