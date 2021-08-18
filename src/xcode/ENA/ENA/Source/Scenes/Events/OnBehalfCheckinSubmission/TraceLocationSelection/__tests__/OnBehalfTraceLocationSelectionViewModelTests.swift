//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfTraceLocationSelectionViewModelTests: CWATestCase {

	func testInitialSetup() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [
				.mock(id: "0".data(using: .utf8) ?? Data()),
				.mock(id: "1".data(using: .utf8) ?? Data()),
				.mock(id: "2".data(using: .utf8) ?? Data())
			]
		)

		XCTAssertEqual(viewModel.title, AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.title)

		XCTAssertEqual(viewModel.traceLocationCellModels.count, 3)
		XCTAssertEqual(
			viewModel.traceLocationCellModels[0].traceLocation.id,
			"0".data(using: .utf8)
		)
		XCTAssertEqual(
			viewModel.traceLocationCellModels[1].traceLocation.id,
			"1".data(using: .utf8)
		)
		XCTAssertEqual(
			viewModel.traceLocationCellModels[2].traceLocation.id,
			"2".data(using: .utf8)
		)

		XCTAssertFalse(viewModel.continueEnabled)
		XCTAssertEqual(viewModel.numberOfSections, 4)
		XCTAssertNil(viewModel.selectedTraceLocation)
	}

	func testNumberOfRowsWithCameraPermissionAuthorized() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .authorized }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 3)
	}

	func testNumberOfRowsWithCameraPermissionNotDetermined() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .notDetermined }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 3)
	}

	func testNumberOfRowsWithCameraPermissionDenied() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .denied }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 3)
	}

	func testNumberOfRowsWithCameraPermissionRestricted() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .restricted }
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 3)
	}

	func testToggleSelection() {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [
				.mock(id: "0".data(using: .utf8) ?? Data()),
				.mock(id: "1".data(using: .utf8) ?? Data()),
				.mock(id: "2".data(using: .utf8) ?? Data())
			]
		)

		XCTAssertNil(viewModel.selectedTraceLocation)
		XCTAssertFalse(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 1)

		XCTAssertEqual(
			viewModel.selectedTraceLocation?.id,
			"1".data(using: .utf8)
		)
		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 1)

		XCTAssertNil(viewModel.selectedTraceLocation)
		XCTAssertFalse(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 2)

		XCTAssertEqual(
			viewModel.selectedTraceLocation?.id,
			"2".data(using: .utf8)
		)
		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 0)

		XCTAssertEqual(
			viewModel.selectedTraceLocation?.id,
			"0".data(using: .utf8)
		)
		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 0)

		XCTAssertNil(viewModel.selectedTraceLocation)
		XCTAssertFalse(viewModel.continueEnabled)
	}

	func testIsEmptyStateVisibleOnEmptyEntriesSectionWithCameraPermission() throws {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [],
			cameraAuthorizationStatus: { .authorized }
		)

		XCTAssertTrue(viewModel.isEmptyStateVisible)
	}

	func testIsEmptyStateVisibleOnEmptyEntriesSectionWithoutCameraPermission() throws {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [],
			cameraAuthorizationStatus: { .denied }
		)

		XCTAssertFalse(viewModel.isEmptyStateVisible)
	}

	func testIsEmptyStateVisibleOnNonEmptyEntriesSectionWithCameraPermission() throws {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .authorized }
		)

		XCTAssertFalse(viewModel.isEmptyStateVisible)
	}

	func testIsEmptyStateVisibleOnNonEmptyEntriesSectionWithoutCameraPermission() throws {
		let viewModel = OnBehalfTraceLocationSelectionViewModel(
			traceLocations: [.mock(), .mock(), .mock()],
			cameraAuthorizationStatus: { .denied }
		)

		XCTAssertFalse(viewModel.isEmptyStateVisible)
	}

}
