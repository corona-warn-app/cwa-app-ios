//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayTest: XCTestCase {

	func testInitialization() throws {
		let dateString = "2020-12-16"
		let entries: [DiaryEntry] = [
			.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow")),
			.contactPerson(DiaryContactPerson(id: 1, name: "Thomas Augsten")),
			.location(DiaryLocation(id: 0, name: "Bäckerei")),
			.location(DiaryLocation(id: 1, name: "Supermarkt"))
		]

		let diaryDay = DiaryDay(
			dateString: dateString,
			entries: entries,
			exposureEncounter: .none
		)

		XCTAssertEqual(diaryDay.dateString, dateString)
		XCTAssertEqual(diaryDay.entries, entries)
	}

	func testSelectedEntries() throws {
		let dateString = "2020-12-16"
		let entries: [DiaryEntry] = [
			.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounterId: 0)),
			.contactPerson(DiaryContactPerson(id: 1, name: "Thomas Augsten")),
			.location(DiaryLocation(id: 0, name: "Bäckerei")),
			.location(DiaryLocation(id: 1, name: "Supermarkt", visitId: 0))
		]

		let diaryDay = DiaryDay(
			dateString: dateString,
			entries: entries,
			exposureEncounter: .none
		)

		XCTAssertEqual(diaryDay.selectedEntries, [
			.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounterId: 0)),
			.location(DiaryLocation(id: 1, name: "Supermarkt", visitId: 0))
		])
	}

	func testFormattedDate() throws {
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [],
			exposureEncounter: .none
		)

		XCTAssertEqual(diaryDay.formattedDate, "Mittwoch, 16.12.20")
	}
	
}
