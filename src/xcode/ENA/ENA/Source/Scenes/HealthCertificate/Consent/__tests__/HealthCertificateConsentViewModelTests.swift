////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateConsentViewModelTests: XCTestCase {

	func testGIVEN_ConsentViewModel_WHEN_getDynamicTableViewModel_THEN_CellsAndSectionsCountAreCorrect() {
		// GIVEN
		let viewModel = HealthCertificateConsentViewModel(didTapDataPrivacy: {})

		// WEHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 8)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 1)
	}

}
