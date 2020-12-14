//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import Combine

class DiaryDayViewModelTest: XCTestCase {

	func testInitialization() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
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
	}

	func testDayIsUpdatedWhenStoreChanges() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
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
			store: store
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
	}

	func testSelectContactPerson() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
		)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(of: .contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer")))

		waitForExpectations(timeout: .medium)

		let entry = try XCTUnwrap(viewModel.day.entries.first {
			guard case .contactPerson(let contactPerson) = $0 else {
				return false
			}

			return contactPerson.id == 1
		})

		XCTAssertTrue(entry.isSelected)
	}

	func testDeselectContactPerson() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
		)

		store.addContactPersonEncounter(contactPersonId: 1, date: day.dateString)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(of: .contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer", encounterId: 0)))

		waitForExpectations(timeout: .medium)

		let entry = try XCTUnwrap(viewModel.day.entries.first {
			guard case .contactPerson(let contactPerson) = $0 else {
				return false
			}

			return contactPerson.id == 1
		})

		XCTAssertFalse(entry.isSelected)
	}

	func testSelectLocation() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
		)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(of: .location(DiaryLocation(id: 0, name: "Supermarket")))

		waitForExpectations(timeout: .medium)

		let entry = try XCTUnwrap(viewModel.day.entries.first {
			guard case .location(let location) = $0 else {
				return false
			}

			return location.id == 0
		})

		XCTAssertTrue(entry.isSelected)
	}

	func testDeselectLocation() throws {
		let day = makeDay()
		let store = makeMockStore()
		let viewModel = DiaryDayViewModel(
			day: day,
			store: store
		)

		store.addLocationVisit(locationId: 0, date: day.dateString)

		let dayPublisherExpectation = expectation(description: "Day publisher called")
		dayPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$day.sink { _ in
			dayPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		viewModel.toggleSelection(of: .location(DiaryLocation(id: 0, name: "Supermarket", visitId: 0)))

		waitForExpectations(timeout: .medium)

		let entry = try XCTUnwrap(viewModel.day.entries.first {
			guard case .location(let location) = $0 else {
				return false
			}

			return location.id == 0
		})

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
			dateString: "2020-12-11",
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
	
}
