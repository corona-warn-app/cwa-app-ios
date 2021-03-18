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
			onAddEntryCellTap: {},
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
			onAddEntryCellTap: {},
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
			onAddEntryCellTap: {},
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
			onAddEntryCellTap: {},
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
			onAddEntryCellTap: {},
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
			onAddEntryCellTap: {},
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.isEmpty)
	}

	func testIsEmptyOnNonEmptyEntriesSection() throws {
		let eventStore = MockEventStore()
		eventStore.createCheckin(Checkin.mock())

		let viewModel = CheckinsOverviewViewModel(
			store: eventStore,
			onAddEntryCellTap: {},
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.isEmpty)
	}

	func testCanEditRowForAddSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onAddEntryCellTap: {},
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.add.rawValue)))
	}

	func testCanEditRowForMissingPermissionSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onAddEntryCellTap: {},
			onEntryCellTap: { _ in }
		)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.missingPermission.rawValue)))
	}

	func testCanEditRowForEntriesSection() throws {
		let viewModel = CheckinsOverviewViewModel(
			store: MockEventStore(),
			onAddEntryCellTap: {},
			onEntryCellTap: { _ in }
		)

		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: CheckinsOverviewViewModel.Section.entries.rawValue)))
	}

}
