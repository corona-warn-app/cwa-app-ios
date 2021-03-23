//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class TraceLocationsOverviewViewModelTest: XCTestCase {

	func testNumberOfSections() throws {
		let viewModel = TraceLocationsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfSections, 2)
	}

	func testNumberOfRowsWithEmptyEntriesSection() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock())
		eventStore.createTraceLocation(TraceLocation.mock())
		eventStore.createTraceLocation(TraceLocation.mock())

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 3)
	}

	func testNumberOfRowsWithNonEmptyEntriesSection() throws {
		let viewModel = TraceLocationsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
	}

	func testIsEmptyOnEmptyEntriesSection() throws {
		let viewModel = TraceLocationsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock())

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForAddSection() throws {
		let viewModel = TraceLocationsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: TraceLocationsOverviewViewModel.Section.add.rawValue)))
	}

	func testCellModels() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock(description: "qwer"))
		eventStore.createTraceLocation(TraceLocation.mock(description: "asdf"))
		eventStore.createTraceLocation(TraceLocation.mock(description: "zxcv"))

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertEqual(
			viewModel.traceLocationCellModel(at: IndexPath(row: 0, section: 1), onUpdate: {}).title,
			"qwer"
		)
		XCTAssertEqual(
			viewModel.traceLocationCellModel(at: IndexPath(row: 1, section: 1), onUpdate: {}).title,
			"asdf"
		)
		XCTAssertEqual(
			viewModel.traceLocationCellModel(at: IndexPath(row: 2, section: 1), onUpdate: {}).title,
			"zxcv"
		)
	}

	func testCanEditRowForEntriesSection() throws {
		let viewModel = TraceLocationsOverviewViewModel(
			store: MockEventStore(),
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: TraceLocationsOverviewViewModel.Section.entries.rawValue)))
	}

	func testDidTapEntryCell() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock(guid: "qwer"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "asdf"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "zxcv"))

		let cellTapExpectation = expectation(description: "onEntryCellTap called")

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: {
				XCTAssertEqual($0.guid, "asdf")
				cellTapExpectation.fulfill()
			},
			onEntryCellButtonTap: { _ in }
		)

		viewModel.didTapEntryCell(at: IndexPath(row: 1, section: 1))

		waitForExpectations(timeout: .medium)
	}

	func testDidTapEntryCellButton() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock(guid: "qwer"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "asdf"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "zxcv"))

		let cellButtonTapExpectation = expectation(description: "onEntryCellButtonTap called")

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: {
				XCTAssertEqual($0.guid, "asdf")
				cellButtonTapExpectation.fulfill()
			}
		)

		viewModel.didTapEntryCellButton(at: IndexPath(row: 1, section: 1))

		waitForExpectations(timeout: .medium)
	}

	func testRemoveEntry() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock(guid: "qwer"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "asdf"))
		eventStore.createTraceLocation(TraceLocation.mock(guid: "zxcv"))

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		viewModel.removeEntry(at: IndexPath(row: 1, section: 1))

		let remainingGUIDs = eventStore.traceLocationsPublisher.value.map { $0.guid }
		XCTAssertEqual(remainingGUIDs, ["qwer", "zxcv"])
	}

	func testRemoveAll() throws {
		let eventStore = MockEventStore()
		eventStore.createTraceLocation(TraceLocation.mock())
		eventStore.createTraceLocation(TraceLocation.mock())
		eventStore.createTraceLocation(TraceLocation.mock())

		let viewModel = TraceLocationsOverviewViewModel(
			store: eventStore,
			onEntryCellTap: { _ in },
			onEntryCellButtonTap: { _ in }
		)

		viewModel.removeAll()

		XCTAssertTrue(eventStore.checkinsPublisher.value.isEmpty)
	}

}
