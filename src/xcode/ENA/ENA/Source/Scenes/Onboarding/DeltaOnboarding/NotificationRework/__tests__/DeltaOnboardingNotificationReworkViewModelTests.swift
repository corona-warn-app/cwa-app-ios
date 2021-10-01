//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DeltaOnboardingNotificationReworkViewModelTests: CWATestCase {
	
	func testGIVEN_ViewModel_WHEN_NumberOfSectionsAndCells_THEN_CorrectNumberOfCells() {
		
		// GIVEN
		
		let viewModel = DeltaOnboardingNotificationReworkViewModel()
		
		// WHEN
		
		let numberOfSections = viewModel.dynamicTableViewModel.numberOfSection
		let numberOfRowsInSection0 = viewModel.dynamicTableViewModel.numberOfRows(section: 0)
		let numberOfRowsInSection1 = viewModel.dynamicTableViewModel.numberOfRows(section: 1)
		let numberOfRowsInSection2 = viewModel.dynamicTableViewModel.numberOfRows(section: 2)
		
		// THEN
		
		XCTAssertEqual(numberOfSections, 3)
		XCTAssertEqual(numberOfRowsInSection0, 2)
		XCTAssertEqual(numberOfRowsInSection1, 6)
		XCTAssertEqual(numberOfRowsInSection2, 2)
	}
}
