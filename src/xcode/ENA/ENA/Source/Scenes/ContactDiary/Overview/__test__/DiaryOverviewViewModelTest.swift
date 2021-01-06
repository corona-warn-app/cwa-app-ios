//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class DiaryOverviewViewModelTest: XCTestCase {

	func testDaysAreUpdatedWhenStoreChanges() throws {
		let store = makeMockStore()
		let viewModel = DiaryOverviewViewModel(
			store: store
		)

		let daysPublisherExpectation = expectation(description: "Days publisher called")
		daysPublisherExpectation.expectedFulfillmentCount = 2

		var subscriptions = [AnyCancellable]()
		viewModel.$days.sink { _ in
			daysPublisherExpectation.fulfill()
		}.store(in: &subscriptions)

		store.addContactPerson(name: "Martin Augst")

		waitForExpectations(timeout: .medium)
	}

	func testNumberOfSections() throws {
		let viewModel = DiaryOverviewViewModel(
			store: makeMockStore()
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testNumberOfRows() throws {
		let viewModel = DiaryOverviewViewModel(
			store: makeMockStore()
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)

		XCTAssertEqual(viewModel.days.count, 14)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 14)
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
	
}
