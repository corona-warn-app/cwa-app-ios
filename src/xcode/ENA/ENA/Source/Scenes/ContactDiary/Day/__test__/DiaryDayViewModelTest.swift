//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class DiaryDayViewModelTest: XCTestCase {

	func testInitialization() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)

		XCTAssertEqual(viewModel.day, day)
		XCTAssertEqual(viewModel.selectedEntryType, .contactPerson)
		XCTAssertEqual(viewModel.entriesOfSelectedType, [
			.contactPerson(DiaryContactPerson(id: 7, name: "Andreas Vogel")),
			.contactPerson(DiaryContactPerson(id: 2, name: "Artur Friesen")),
			.contactPerson(DiaryContactPerson(id: 6, name: "Carsten Knoblich")),
			.contactPerson(DiaryContactPerson(id: 4, name: "Kai Teuber")),
			.contactPerson(DiaryContactPerson(id: 5, name: "Karsten Gahn")),
			.contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer")),
			.contactPerson(DiaryContactPerson(id: 0, name: "Nick Gündling")),
			.contactPerson(DiaryContactPerson(id: 9, name: "Omar Ahmed")),
			.contactPerson(DiaryContactPerson(id: 3, name: "Pascal Brause")),
			.contactPerson(DiaryContactPerson(id: 8, name: "Puneet Mahali"))
		])
		XCTAssertEqual(viewModel.numberOfSections, 2)
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 10)
	}

	func testDayIsUpdatedWhenStoreChanges() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		store.addContactPerson(name: "Janet Back")

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(viewModel.day, store.diaryDaysPublisher.value.first { $0.dateString == day.dateString })
	}

	func testEntriesOfSelectedTypeAreUpdatedOnEntryTypeSelection() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)

		let selectedEntryTypePublisherExpectation = expectation(description: "SelectedEntryType publisher called")
		selectedEntryTypePublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$selectedEntryType.sink { _ in
			selectedEntryTypePublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.selectedEntryType = .location

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(viewModel.entriesOfSelectedType, [
			.location(DiaryLocation(id: 1, name: "Bakery")),
			.location(DiaryLocation(id: 0, name: "Supermarket"))
		])
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 2)
	}

	func testDidTapAddEntryCellForContactPersons() {
		let onAddEntryCellTapExpectation = expectation(description: "onAddEntryCellTap called")

		let mockDay = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: mockDay,
			store: store,
			onAddEntryCellTap: { day, entryType in
				XCTAssertEqual(day, mockDay)
				XCTAssertEqual(entryType, .contactPerson)

				onAddEntryCellTapExpectation.fulfill()
			}
		)

		viewModel.didTapAddEntryCell()

		waitForExpectations(timeout: .medium)
	}

	func testDidTapAddEntryCellForLocations() {
		let onAddEntryCellTapExpectation = expectation(description: "onAddEntryCellTap called")

		let mockDay = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: mockDay,
			store: store,
			onAddEntryCellTap: { day, entryType in
				XCTAssertEqual(day, mockDay)
				XCTAssertEqual(entryType, .location)

				onAddEntryCellTapExpectation.fulfill()
			}
		)
		viewModel.selectedEntryType = .location

		viewModel.didTapAddEntryCell()

		waitForExpectations(timeout: .medium)
	}

	func testSelectContactPerson() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(at: IndexPath(row: 5, section: DiaryDayViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)

		let entry = viewModel.entriesOfSelectedType[5]

		XCTAssertTrue(entry.isSelected)
	}

	func testDeselectContactPerson() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)

		store.addContactPersonEncounter(contactPersonId: 1, date: day.dateString)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(at: IndexPath(row: 5, section: DiaryDayViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)

		let entry = viewModel.entriesOfSelectedType[5]

		XCTAssertFalse(entry.isSelected)
	}

	func testSelectLocation() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)
		viewModel.selectedEntryType = .location

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(at: IndexPath(row: 1, section: DiaryDayViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)

		let entry = viewModel.entriesOfSelectedType[1]

		XCTAssertTrue(entry.isSelected)
	}

	func testDeselectLocation() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store,
			onAddEntryCellTap: { _, _ in }
		)
		viewModel.selectedEntryType = .location

		store.addLocationVisit(locationId: 0, date: day.dateString)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(at: IndexPath(row: 1, section: DiaryDayViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)

		let entry = viewModel.entriesOfSelectedType[1]

		XCTAssertFalse(entry.isSelected)
	}

	// MARK: - Private Helpers

	func makeMockStore() -> MockDiaryStore {
		let store = MockDiaryStore()
		store.addContactPerson(name: "Nick Gündling")
		store.addContactPerson(name: "Marcus Scherer")
		store.addContactPerson(name: "Artur Friesen")
		store.addContactPerson(name: "Pascal Brause")
		store.addContactPerson(name: "Kai Teuber")
		store.addContactPerson(name: "Karsten Gahn")
		store.addContactPerson(name: "Carsten Knoblich")
		store.addContactPerson(name: "Andreas Vogel")
		store.addContactPerson(name: "Puneet Mahali")
		store.addContactPerson(name: "Omar Ahmed")
		store.addLocation(name: "Supermarket")
		store.addLocation(name: "Bakery")

		return store
	}

	func makeDay() -> DiaryDay {
		return DiaryDay(
			dateString: dateFormatter.string(from: Date()),
			entries: [
				.contactPerson(DiaryContactPerson(id: 7, name: "Andreas Vogel")),
				.contactPerson(DiaryContactPerson(id: 2, name: "Artur Friesen")),
				.contactPerson(DiaryContactPerson(id: 6, name: "Carsten Knoblich")),
				.contactPerson(DiaryContactPerson(id: 4, name: "Kai Teuber")),
				.contactPerson(DiaryContactPerson(id: 5, name: "Karsten Gahn")),
				.contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer")),
				.contactPerson(DiaryContactPerson(id: 0, name: "Nick Gündling")),
				.contactPerson(DiaryContactPerson(id: 9, name: "Omar Ahmed")),
				.contactPerson(DiaryContactPerson(id: 3, name: "Pascal Brause")),
				.contactPerson(DiaryContactPerson(id: 8, name: "Puneet Mahali")),
				.location(DiaryLocation(id: 1, name: "Bakery")),
				.location(DiaryLocation(id: 0, name: "Supermarket"))
			]
		)
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
	
}
