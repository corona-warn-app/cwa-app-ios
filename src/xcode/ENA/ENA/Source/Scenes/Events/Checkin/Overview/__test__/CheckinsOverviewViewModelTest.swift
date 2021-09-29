//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class CheckinsOverviewViewModelTest: CWATestCase {

	func testNumberOfSections() throws {
		let eventStore = MockEventStore()

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let eventStore = MockEventStore()

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForAddSection() throws {
		let eventStore = MockEventStore()

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.add.rawValue)))
	}

	func testCanEditRowForEntriesSection() throws {
		let eventStore = MockEventStore()

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.entries.rawValue)))
	}

	func testDidTapEntryCell() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: -10)))
		eventStore.createCheckin(Checkin.mock(traceLocationId: "137".data(using: .utf8) ?? Data(), checkinStartDate: Date()))
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: 10)))

		let cellTapExpectation = expectation(description: "onEntryCellTap called")

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: {
				XCTAssertEqual($0.traceLocationId, "137".data(using: .utf8))
				cellTapExpectation.fulfill()
			}
		)

		viewModel.didTapEntryCell(at: IndexPath(row: 1, section: CheckinsOverviewViewModel.Section.entries.rawValue))

		waitForExpectations(timeout: .medium)
	}

	func testDidTapEntryCellButton() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(), checkinEndDate: Date(timeIntervalSinceNow: -100)))
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "137".data(using: .utf8) ?? Data(), checkinStartDate: Date(timeIntervalSinceNow: -100), checkinEndDate: Date(timeIntervalSinceNow: -10), checkinCompleted: false)
		)
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: 10)))

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		viewModel.didTapEntryCellButton(at: IndexPath(row: 1, section: CheckinsOverviewViewModel.Section.entries.rawValue))

		let tappedCheckin = eventStore.checkinsPublisher.value.first {
			$0.traceLocationId == "137".data(using: .utf8)
		}
		XCTAssertTrue(tappedCheckin?.checkinCompleted ?? false)
	}

	func testRemoveEntry() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "17".data(using: .utf8) ?? Data(), checkinStartDate: Date(timeIntervalSinceNow: -10))
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "137".data(using: .utf8) ?? Data(), checkinStartDate: Date())
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "964".data(using: .utf8) ?? Data(), checkinStartDate: Date(timeIntervalSinceNow: 10))
		)

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		viewModel.removeEntry(at: IndexPath(row: 1, section: 2))

		let remainingGUIDs = eventStore.checkinsPublisher.value
			.sorted { $0.checkinStartDate < $1.checkinStartDate }
			.map { $0.traceLocationId }

		XCTAssertEqual(remainingGUIDs, ["17".data(using: .utf8), "964".data(using: .utf8)])
	}

	func testRemoveAll() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		viewModel.removeAll()

		XCTAssertTrue(eventStore.checkinsPublisher.value.isEmpty)
	}

	func testEntrySortingByCheckinStartDate() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "17".data(using: .utf8) ?? Data(), checkinEndDate: Date(timeIntervalSinceNow: 10))
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "964".data(using: .utf8) ?? Data(), checkinEndDate: .distantFuture)
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "137".data(using: .utf8) ?? Data(), checkinEndDate: Date())
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "qwerty".data(using: .utf8) ?? Data(), checkinEndDate: .distantPast)
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationId: "asdf".data(using: .utf8) ?? Data(), checkinEndDate: Date(timeIntervalSinceNow: -220))
		)

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		let traceLocationIds = viewModel.checkinCellModels
			.map { $0.checkin.traceLocationId }

		XCTAssertEqual(traceLocationIds, ["964".data(using: .utf8), "17".data(using: .utf8), "137".data(using: .utf8), "asdf".data(using: .utf8), "qwerty".data(using: .utf8)])
	}

	func testAddedCheckinTriggersReload() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		let reloadExpectation = expectation(description: "triggerReload published")
		reloadExpectation.expectedFulfillmentCount = 2 // initial call + update for added checkin
		let cancellable = viewModel.$triggerReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		eventStore.createCheckin(Checkin.mock())

		waitForExpectations(timeout: .medium)

		cancellable.cancel()
	}

	func testDeletedCheckinTriggersReload() throws {
		let eventStore = MockEventStore()
		let idResult = eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		guard case .success(let id) = idResult else {
			XCTFail("Failed to create checkin")
			return
		}

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		let reloadExpectation = expectation(description: "triggerReload published")
		reloadExpectation.expectedFulfillmentCount = 2 // initial call + update for removed checkin
		let cancellable = viewModel.$triggerReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		eventStore.deleteCheckin(id: id)

		waitForExpectations(timeout: .medium)

		cancellable.cancel()
	}

	func testUpdatedCheckinDoesNotTriggersReloadButUpdate() throws {
		let eventStore = MockEventStore()
		let endDate = Date()
		let idResult = eventStore.createCheckin(
			Checkin.mock(traceLocationId: "abc".data(using: .utf8) ?? Data(), checkinStartDate: Date(timeIntervalSinceNow: -100), checkinEndDate: Date(), checkinCompleted: false)
		)
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(), checkinEndDate: Date(timeIntervalSinceNow: 100)))

		guard case .success(let id) = idResult else {
			XCTFail("Failed to create checkin")
			return
		}

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			eventCheckoutService: EventCheckoutService(
				eventStore: eventStore,
				contactDiaryStore: MockDiaryStore()
			),
			onEntryCellTap: { _ in }
		)

		let onUpdateExpectation = expectation(description: "onUpdate called")
		onUpdateExpectation.assertForOverFulfill = false
		viewModel.onUpdate = {
			onUpdateExpectation.fulfill()
		}

		let reloadExpectation = expectation(description: "triggerReload published only once")
		reloadExpectation.expectedFulfillmentCount = 1
		let cancellable = viewModel.$triggerReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		eventStore.updateCheckin(Checkin.mock(id: id, traceLocationId: "abc".data(using: .utf8) ?? Data(), checkinStartDate: Date(timeIntervalSinceNow: -100), checkinEndDate: endDate))

		waitForExpectations(timeout: 100)

		cancellable.cancel()
	}

}
