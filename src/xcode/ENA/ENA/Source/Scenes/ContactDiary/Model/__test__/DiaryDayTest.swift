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
			entries: entries
		)

		XCTAssertEqual(diaryDay.dateString, dateString)
		XCTAssertEqual(diaryDay.entries, entries)
	}

	func testSelectedEntries() throws {
		let dateString = "2020-12-16"

		let selectedContactPerson = DiaryContactPerson(
			id: 0,
			name: "Thomas Mesow",
			encounter: ContactPersonEncounter(
				id: 0,
				date: dateString,
				contactPersonId: 0
			)
		)

		let selectedLocation = DiaryLocation(
			id: 1,
			name: "Supermarkt",
			visit: LocationVisit(
				id: 0,
				date: dateString,
				locationId: 1
			)
		)

		let entries: [DiaryEntry] = [
			.contactPerson(
				selectedContactPerson
			),
			.contactPerson(
				DiaryContactPerson(
					id: 1,
					name: "Thomas Augsten"
				)
			),
			.location(
				DiaryLocation(
					id: 0,
					name: "Bäckerei"
				)
			),
			.location(
				selectedLocation
			)
		]

		let diaryDay = DiaryDay(
			dateString: dateString,
			entries: entries
		)

		XCTAssertEqual(diaryDay.selectedEntries, [
			.contactPerson(selectedContactPerson),
			.location(selectedLocation)
		])
	}

	func testFormattedDate() throws {
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: []
		)

		XCTAssertEqual(diaryDay.formattedDate, "Mittwoch, 16.12.20")
	}
	
}
