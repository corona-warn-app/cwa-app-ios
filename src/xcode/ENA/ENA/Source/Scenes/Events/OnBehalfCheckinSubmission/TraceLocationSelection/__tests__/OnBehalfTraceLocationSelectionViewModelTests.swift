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

}
