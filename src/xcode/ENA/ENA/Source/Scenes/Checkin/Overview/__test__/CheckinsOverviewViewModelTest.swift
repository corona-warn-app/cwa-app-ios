//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class CheckinsOverviewViewModelTest: XCTestCase {

	func testNumberOfSections() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfSections, 3)
	}

	func testNumberOfRowsWithCameraPermissionAuthorized() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			cameraAuthorizationStatus: { .authorized }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 3)
	}

	func testNumberOfRowsWithCameraPermissionNotDetermined() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			cameraAuthorizationStatus: { .notDetermined }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
	}

	func testNumberOfRowsWithCameraPermissionDenied() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			cameraAuthorizationStatus: { .denied }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
	}

	func testNumberOfRowsWithCameraPermissionRestricted() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			cameraAuthorizationStatus: { .restricted }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForAddSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.add.rawValue)))
	}

	func testCanEditRowForMissingPermissionSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.missingPermission.rawValue)))
	}

	func testCanEditRowForEntriesSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.entries.rawValue)))
	}

	func testDidTapEntryCell() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: -10)))
		eventStore.createCheckin(Checkin.mock(traceLocationGUID: "137", checkinStartDate: Date()))
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: 10)))

		let cellTapExpectation = expectation(description: "onEntryCellTap called")

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: {
				XCTAssertEqual($0.traceLocationGUID, "137")
				cellTapExpectation.fulfill()
			}
		)

		viewModel.didTapEntryCell(at: IndexPath(row: 1, section: 2))

		waitForExpectations(timeout: .medium)
	}

	func testDidTapEntryCellButton() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: -10)))
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "137", checkinStartDate: Date(), checkinEndDate: nil)
		)
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date(timeIntervalSinceNow: 10)))

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		viewModel.didTapEntryCellButton(at: IndexPath(row: 1, section: 2))

		let tappedCheckin = eventStore.checkinsPublisher.value.first {
			$0.traceLocationGUID == "137"
		}
		XCTAssertNotNil(tappedCheckin?.checkinEndDate)
	}

	func testRemoveEntry() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "17", checkinStartDate: Date(timeIntervalSinceNow: -10))
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "137", checkinStartDate: Date())
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "964", checkinStartDate: Date(timeIntervalSinceNow: 10))
		)

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		viewModel.removeEntry(at: IndexPath(row: 1, section: 2))

		let remainingGUIDs = eventStore.checkinsPublisher.value
			.sorted { $0.checkinStartDate < $1.checkinStartDate }
			.map { $0.traceLocationGUID }

		XCTAssertEqual(remainingGUIDs, ["17", "964"])
	}

	func testRemoveAll() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		viewModel.removeAll()

		XCTAssertTrue(eventStore.checkinsPublisher.value.isEmpty)
	}

	func testUpdateForCameraPermission() throws {
		let reloadExpectation = expectation(description: "shouldReload published")
		reloadExpectation.expectedFulfillmentCount = 2 // initial call + update for camera permission

		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in }
		)

		let cancellable = viewModel.$shouldReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		viewModel.updateForCameraPermission()

		waitForExpectations(timeout: .medium)

		cancellable.cancel()
	}

	func testEntrySortingByCheckinStartDate() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "17", checkinStartDate: Date(timeIntervalSinceNow: 10))
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "964", checkinStartDate: .distantFuture)
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "137", checkinStartDate: Date())
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "qwerty", checkinStartDate: .distantPast)
		)
		eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "asdf", checkinStartDate: Date(timeIntervalSinceNow: -220))
		)

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		let traceLocationGUIDs = viewModel.checkinCellModels
			.map { $0.checkin.traceLocationGUID }

		XCTAssertEqual(traceLocationGUIDs, ["qwerty", "asdf", "137", "17", "964"])
	}

	func testAddedCheckinTriggersReload() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		let reloadExpectation = expectation(description: "shouldReload published")
		reloadExpectation.expectedFulfillmentCount = 2 // initial call + update for added checkin
		let cancellable = viewModel.$shouldReload
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
			onEntryCellTap: { _ in }
		)

		let reloadExpectation = expectation(description: "shouldReload published")
		reloadExpectation.expectedFulfillmentCount = 2 // initial call + update for removed checkin
		let cancellable = viewModel.$shouldReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		eventStore.deleteCheckin(id: id)

		waitForExpectations(timeout: .medium)

		cancellable.cancel()
	}

	func testUpdatedCheckinDoesNotTriggersReloadButUpdate() throws {
		let eventStore = MockEventStore()
		let idResult = eventStore.createCheckin(
			Checkin.mock(traceLocationGUID: "abc", checkinStartDate: Date(timeIntervalSinceNow: -100), checkinEndDate: nil)
		)
		eventStore.createCheckin(Checkin.mock(checkinStartDate: Date()))

		guard case .success(let id) = idResult else {
			XCTFail("Failed to create checkin")
			return
		}

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in }
		)

		let onUpdateExpectation = expectation(description: "onUpdate called")
		onUpdateExpectation.assertForOverFulfill = false
		viewModel.onUpdate = {
			onUpdateExpectation.fulfill()
		}

		let reloadExpectation = expectation(description: "shouldReload published only once")
		reloadExpectation.expectedFulfillmentCount = 1
		let cancellable = viewModel.$shouldReload
			.sink { _ in
				reloadExpectation.fulfill()
			}

		eventStore.updateCheckin(Checkin.mock(id: id, traceLocationGUID: "abc", checkinStartDate: Date(timeIntervalSinceNow: -100), checkinEndDate: Date()))

		waitForExpectations(timeout: 100)

		cancellable.cancel()
	}

}
