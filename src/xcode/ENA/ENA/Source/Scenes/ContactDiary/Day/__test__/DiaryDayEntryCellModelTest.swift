//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayEntryCellModelTest: XCTestCase {

	func testContactPersonUnselected() throws {
		let entry: DiaryEntry = .contactPerson(
			DiaryContactPerson(
				id: 0,
				name: "Nick Guendling"
			)
		)
		let cellModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-01-01", store: MockDiaryStore())

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(cellModel.text, "Nick Guendling")
		XCTAssertEqual(cellModel.font, .enaFont(for: .body))

		XCTAssertEqual(cellModel.entryType, .contactPerson)
		XCTAssertTrue(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, .button)
	}

	func testContactPersonSelected() throws {
		let entry: DiaryEntry = .contactPerson(
			DiaryContactPerson(
				id: 0,
				name: "Marcus Scherer",
				encounter: ContactPersonEncounter(
					id: 0,
					date: "2021-02-11",
					contactPersonId: 0
				)
			)
		)
		let cellModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-02-11", store: MockDiaryStore())

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(cellModel.text, "Marcus Scherer")
		XCTAssertEqual(cellModel.font, .enaFont(for: .headline))

		XCTAssertEqual(cellModel.entryType, .contactPerson)
		XCTAssertFalse(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, [.button, .selected])
	}

	func testLocationUnselected() throws {
		let entry: DiaryEntry = .location(
			DiaryLocation(
				id: 0,
				name: "Bakery"
			)
		)
		let cellModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-01-01", store: MockDiaryStore())

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(cellModel.text, "Bakery")
		XCTAssertEqual(cellModel.font, .enaFont(for: .body))

		XCTAssertEqual(cellModel.entryType, .location)
		XCTAssertTrue(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, .button)
	}

	func testLocationSelected() throws {
		let entry: DiaryEntry = .location(
			DiaryLocation(
				id: 0,
				name: "Supermarket",
				visit: LocationVisit(
					id: 0,
					date: "2021-02-11",
					locationId: 0
				)
			)
		)
		let cellModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-02-11", store: MockDiaryStore())

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(cellModel.text, "Supermarket")
		XCTAssertEqual(cellModel.font, .enaFont(for: .headline))

		XCTAssertEqual(cellModel.entryType, .location)
		XCTAssertFalse(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, [.button, .selected])
	}
	
}
