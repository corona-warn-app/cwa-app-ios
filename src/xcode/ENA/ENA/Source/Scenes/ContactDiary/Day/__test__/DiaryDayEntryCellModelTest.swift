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
		let viewModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-01-01", store: MockDiaryStore())

		XCTAssertEqual(viewModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(viewModel.text, "Nick Guendling")
		XCTAssertEqual(viewModel.font, .enaFont(for: .body))

		XCTAssertEqual(viewModel.entryType, .contactPerson)
		XCTAssertTrue(viewModel.parametersHidden)

		XCTAssertEqual(viewModel.accessibilityTraits, .button)
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
		let viewModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-02-11", store: MockDiaryStore())

		XCTAssertEqual(viewModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(viewModel.text, "Marcus Scherer")
		XCTAssertEqual(viewModel.font, .enaFont(for: .headline))

		XCTAssertEqual(viewModel.entryType, .contactPerson)
		XCTAssertFalse(viewModel.parametersHidden)

		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])
	}

	func testLocationUnselected() throws {
		let entry: DiaryEntry = .location(
			DiaryLocation(
				id: 0,
				name: "Bakery"
			)
		)
		let viewModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-01-01", store: MockDiaryStore())

		XCTAssertEqual(viewModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(viewModel.text, "Bakery")
		XCTAssertEqual(viewModel.font, .enaFont(for: .body))

		XCTAssertEqual(viewModel.entryType, .location)
		XCTAssertTrue(viewModel.parametersHidden)

		XCTAssertEqual(viewModel.accessibilityTraits, .button)
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
		let viewModel = DiaryDayEntryCellModel(entry: entry, dateString: "2021-02-11", store: MockDiaryStore())

		XCTAssertEqual(viewModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(viewModel.text, "Supermarket")
		XCTAssertEqual(viewModel.font, .enaFont(for: .headline))

		XCTAssertEqual(viewModel.entryType, .location)
		XCTAssertFalse(viewModel.parametersHidden)

		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])
	}
	
}
