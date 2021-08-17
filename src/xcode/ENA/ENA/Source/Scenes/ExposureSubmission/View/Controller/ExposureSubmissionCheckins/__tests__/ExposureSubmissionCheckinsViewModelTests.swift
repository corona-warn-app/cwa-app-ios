//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionCheckinsViewModelTests: CWATestCase {

	func testInitialSetup() {
		let viewModel = ExposureSubmissionCheckinsViewModel(checkins: [])

		XCTAssertEqual(viewModel.title, AppStrings.ExposureSubmissionCheckins.title)
		XCTAssertEqual(viewModel.checkinCellModels.count, 0)
		XCTAssertFalse(viewModel.continueEnabled)
		XCTAssertEqual(viewModel.numberOfSections, 2)
		XCTAssertEqual(viewModel.selectedCheckins.count, 0)
	}

	func testInitialCheckinCellModelsOnlyContainCompletedCheckins() {
		let viewModel = ExposureSubmissionCheckinsViewModel(
			checkins: [
				.mock(id: 0, checkinCompleted: false),
				.mock(id: 1, checkinCompleted: true),
				.mock(id: 2, checkinCompleted: false),
				.mock(id: 3, checkinCompleted: false),
				.mock(id: 4, checkinCompleted: true)
			]
		)

		XCTAssertEqual(viewModel.checkinCellModels.count, 2)
		XCTAssertEqual(viewModel.checkinCellModels[0].checkin.id, 1)
		XCTAssertEqual(viewModel.checkinCellModels[1].checkin.id, 4)
	}

	func testNumberOfRows() {
		let viewModel = ExposureSubmissionCheckinsViewModel(
			checkins: [
				.mock(checkinCompleted: true),
				.mock(checkinCompleted: true),
				.mock(checkinCompleted: false),
				.mock(checkinCompleted: true),
				.mock(checkinCompleted: false)
			]
		)

		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 3)
	}

	func testSelectAll() {
		let viewModel = ExposureSubmissionCheckinsViewModel(
			checkins: [
				.mock(id: 0, checkinCompleted: true),
				.mock(id: 1, checkinCompleted: true),
				.mock(id: 2, checkinCompleted: true),
				.mock(id: 3, checkinCompleted: false),
				.mock(id: 4, checkinCompleted: true)
			]
		)

		XCTAssertEqual(viewModel.selectedCheckins.count, 0)
		XCTAssertFalse(viewModel.continueEnabled)

		viewModel.selectAll()

		XCTAssertEqual(viewModel.selectedCheckins.count, 4)

		XCTAssertEqual(viewModel.selectedCheckins[0].id, 0)
		XCTAssertEqual(viewModel.selectedCheckins[1].id, 1)
		XCTAssertEqual(viewModel.selectedCheckins[2].id, 2)
		XCTAssertEqual(viewModel.selectedCheckins[3].id, 4)

		XCTAssertTrue(viewModel.continueEnabled)

		// Check that second call keeps selection
		viewModel.selectAll()

		XCTAssertEqual(viewModel.selectedCheckins.count, 4)
		XCTAssertTrue(viewModel.continueEnabled)
	}

	func testToggleSelection() {
		let viewModel = ExposureSubmissionCheckinsViewModel(
			checkins: [
				.mock(id: 0, checkinCompleted: true),
				.mock(id: 1, checkinCompleted: false),
				.mock(id: 2, checkinCompleted: true),
				.mock(id: 3, checkinCompleted: false),
				.mock(id: 4, checkinCompleted: true)
			]
		)

		XCTAssertEqual(viewModel.selectedCheckins.count, 0)
		XCTAssertFalse(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 1)

		XCTAssertEqual(viewModel.selectedCheckins.count, 1)
		XCTAssertEqual(viewModel.selectedCheckins[0].id, 2)

		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 1)

		XCTAssertEqual(viewModel.selectedCheckins.count, 0)
		XCTAssertFalse(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 2)

		XCTAssertEqual(viewModel.selectedCheckins.count, 1)
		XCTAssertEqual(viewModel.selectedCheckins[0].id, 4)

		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 0)

		XCTAssertEqual(viewModel.selectedCheckins.count, 2)
		XCTAssertEqual(viewModel.selectedCheckins[0].id, 0)
		XCTAssertEqual(viewModel.selectedCheckins[1].id, 4)

		XCTAssertTrue(viewModel.continueEnabled)

		viewModel.toggleSelection(at: 1)

		XCTAssertEqual(viewModel.selectedCheckins.count, 3)
		XCTAssertEqual(viewModel.selectedCheckins[0].id, 0)
		XCTAssertEqual(viewModel.selectedCheckins[1].id, 2)
		XCTAssertEqual(viewModel.selectedCheckins[2].id, 4)

		XCTAssertTrue(viewModel.continueEnabled)
	}

}
