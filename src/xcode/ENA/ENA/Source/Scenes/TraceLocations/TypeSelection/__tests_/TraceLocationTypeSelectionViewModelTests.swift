////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationTypeSelectionViewModelTests: XCTestCase {

	func testGIVEN_SectionNames_THEN_NamesMatch() {
		// GIVEN
		let locationSectionName = TraceLocationTypeSelectionViewModel.TraceLocationSection.location.title
		let eventsSectionName = TraceLocationTypeSelectionViewModel.TraceLocationSection.event.title

		// THEN
		XCTAssertEqual(locationSectionName, AppStrings.TraceLocations.permanent.name)
		XCTAssertEqual(eventsSectionName, AppStrings.TraceLocations.temporary.name)
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

}
