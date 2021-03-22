////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationTypeSelectionViewModelTests: XCTestCase {

	func testGIVEN_SectionNames_THEN_NamesMatch() {
		// GIVEN
		let viewModel = TraceLocationTypeSelectionViewModel(
			[.location: [],
			 .event: []
			],
			onTraceLocationTypeSelection: { _ in }
		)
		let locationSectionName = TraceLocationTypeSelectionViewModel.TraceLocationSection.location.title
		let eventsSectionName = TraceLocationTypeSelectionViewModel.TraceLocationSection.event.title

		// THEN
		XCTAssertEqual(locationSectionName, viewModel.sectionTitle(for: 0))
		XCTAssertEqual(eventsSectionName, viewModel.sectionTitle(for: 1))
	}

	func testGIVEN_ViewModel_WHEN_getNumberOfSectionsAndRows_THEN_Matches() {
		// GIVEN
		let viewModel = TraceLocationTypeSelectionViewModel(
			[.location: [.locationTypePermanentOther, .locationTypePermanentFoodService, .locationTypePermanentRetail],
			 .event: [.locationTypeTemporaryOther, .locationTypeTemporaryClubActivity]
			],
			onTraceLocationTypeSelection: { _ in }
		)

		// WHEN
		let sectionsCount = viewModel.numberOfSections
		let locationsCount = viewModel.numberOfRows(in: 0)
		let eventsCount = viewModel.numberOfRows(in: 1)
		let unknownCount = viewModel.numberOfRows(in: 2)

		// THEN
		XCTAssertEqual(sectionsCount, 2)
		XCTAssertEqual(locationsCount, 3)
		XCTAssertEqual(eventsCount, 2)
		XCTAssertEqual(unknownCount, 0)
	}

	func testGIVEN_ViewModel_WHEN_getCellModel_THEN_TraceLocationTypeIsCorrect() {
		// GIVEN
		let viewModel = TraceLocationTypeSelectionViewModel(
			[.location: [.locationTypePermanentOther, .locationTypePermanentFoodService, .locationTypePermanentRetail],
			 .event: [.locationTypeTemporaryOther, .locationTypeTemporaryClubActivity]
			],
			onTraceLocationTypeSelection: { _ in }
		)

		// WHEN
		let eventCellModel = viewModel.cellViewModel(at: IndexPath(row: 1, section: 1))
		let locationCellModel = viewModel.cellViewModel(at: IndexPath(row: 2, section: 0))
		let unknownCellModel = viewModel.cellViewModel(at: IndexPath(row: 1000, section: 10))

		// THEN
		XCTAssertEqual(eventCellModel, .locationTypeTemporaryClubActivity)
		XCTAssertEqual(locationCellModel, .locationTypePermanentRetail)
		XCTAssertEqual(unknownCellModel, .locationTypeUnspecified)
	}


	func testGIVEN_ViewModel_WHEN_SelectTraceLocationType_THEN_TraceLocationTypeSelectedIsCorrect() {
		// GIVEN
		var selection: TraceLocationType?
		let didSelectExpectation = expectation(description: "did select traceLocationType")
		let viewModel = TraceLocationTypeSelectionViewModel(
			[.location: [.locationTypePermanentOther, .locationTypePermanentFoodService, .locationTypePermanentRetail],
			 .event: [.locationTypeTemporaryOther, .locationTypeTemporaryClubActivity]
			],
			onTraceLocationTypeSelection: { traceLocationType in
				selection = traceLocationType
				didSelectExpectation.fulfill()
			}
		)

		viewModel.selectTraceLocationType(at: IndexPath(row: 1, section: 1))
		wait(for: [didSelectExpectation], timeout: .medium)

		// THEN
		XCTAssertEqual(selection, .locationTypeTemporaryClubActivity)
	}

	func testGIVEN_ViewModel_WHEN_SelectInvalidTraceLocationType_THEN_NotClosureCetsCalled() {
		// GIVEN
		var selection: TraceLocationType?
		let didSelectExpectation = expectation(description: "did select traceLocationType")
		didSelectExpectation.isInverted = true

		let viewModel = TraceLocationTypeSelectionViewModel(
			[.location: [],
			 .event: [.locationTypeTemporaryOther, .locationTypeTemporaryClubActivity]
			],
			onTraceLocationTypeSelection: { traceLocationType in
				selection = traceLocationType
				didSelectExpectation.fulfill()
			}
		)

		viewModel.selectTraceLocationType(at: IndexPath(row: 6, section: 25))
		wait(for: [didSelectExpectation], timeout: .short)

		// THEN
		XCTAssertNil(selection)
	}


}
