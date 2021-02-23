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
		XCTAssertEqual(viewModel.accessibilityTraits, [.button, .selected])
	}

//	func testSelectContactPerson() throws {
//		let day = makeDay()
//		let store = makeMockStore()
//		let viewModel = DiaryDayViewModel(
//			day: day,
//			store: store,
//			onAddEntryCellTap: { _, _ in }
//		)
//
//		let dayPublisherExpectation = expectation(description: "Day publisher called")
//		dayPublisherExpectation.expectedFulfillmentCount = 2
//
//		var subscriptions = [AnyCancellable]()
//		viewModel.$day.sink { _ in
//			dayPublisherExpectation.fulfill()
//		}.store(in: &subscriptions)
//
//		viewModel.toggleSelection(at: IndexPath(row: 5, section: DiaryDayViewModel.Section.entries.rawValue))
//
//		waitForExpectations(timeout: .medium)
//
//		let entry = viewModel.entriesOfSelectedType[5]
//
//		XCTAssertTrue(entry.isSelected)
//	}
//
//	func testDeselectContactPerson() throws {
//		let day = makeDay()
//		let store = makeMockStore()
//		let viewModel = DiaryDayViewModel(
//			day: day,
//			store: store,
//			onAddEntryCellTap: { _, _ in }
//		)
//
//		store.addContactPersonEncounter(contactPersonId: 1, date: day.dateString)
//
//		let dayPublisherExpectation = expectation(description: "Day publisher called")
//		dayPublisherExpectation.expectedFulfillmentCount = 2
//
//		var subscriptions = [AnyCancellable]()
//		viewModel.$day.sink { _ in
//			dayPublisherExpectation.fulfill()
//		}.store(in: &subscriptions)
//
//		viewModel.toggleSelection(at: IndexPath(row: 5, section: DiaryDayViewModel.Section.entries.rawValue))
//
//		waitForExpectations(timeout: .medium)
//
//		let entry = viewModel.entriesOfSelectedType[5]
//
//		XCTAssertFalse(entry.isSelected)
//	}
//
//	func testSelectLocation() throws {
//		let day = makeDay()
//		let store = makeMockStore()
//		let viewModel = DiaryDayViewModel(
//			day: day,
//			store: store,
//			onAddEntryCellTap: { _, _ in }
//		)
//		viewModel.selectedEntryType = .location
//
//		let dayPublisherExpectation = expectation(description: "Day publisher called")
//		dayPublisherExpectation.expectedFulfillmentCount = 2
//
//		var subscriptions = [AnyCancellable]()
//		viewModel.$day.sink { _ in
//			dayPublisherExpectation.fulfill()
//		}.store(in: &subscriptions)
//
//		viewModel.toggleSelection(at: IndexPath(row: 1, section: DiaryDayViewModel.Section.entries.rawValue))
//
//		waitForExpectations(timeout: .medium)
//
//		let entry = viewModel.entriesOfSelectedType[1]
//
//		XCTAssertTrue(entry.isSelected)
//	}
//
//	func testDeselectLocation() throws {
//		let day = makeDay()
//		let store = makeMockStore()
//		let viewModel = DiaryDayViewModel(
//			day: day,
//			store: store,
//			onAddEntryCellTap: { _, _ in }
//		)
//		viewModel.selectedEntryType = .location
//
//		store.addLocationVisit(locationId: 0, date: day.dateString)
//
//		let dayPublisherExpectation = expectation(description: "Day publisher called")
//		dayPublisherExpectation.expectedFulfillmentCount = 2
//
//		var subscriptions = [AnyCancellable]()
//		viewModel.$day.sink { _ in
//			dayPublisherExpectation.fulfill()
//		}.store(in: &subscriptions)
//
//		viewModel.toggleSelection(at: IndexPath(row: 1, section: DiaryDayViewModel.Section.entries.rawValue))
//
//		waitForExpectations(timeout: .medium)
//
//		let entry = viewModel.entriesOfSelectedType[1]
//
//		XCTAssertFalse(entry.isSelected)
//	}
	
}
