//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CovPassCheckInformationViewModelTests: XCTestCase {

	func testGIVEN_ViewModel_WHEN_getDataSource_THEN_SectionAndCellCountMatch() {
		// GIVEN
		let viewModel = CovPassCheckInformationViewModel()

		// WHEN
		let dataSource = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dataSource.numberOfSection, 1)
		XCTAssertEqual(dataSource.numberOfRows(section: 0), 9)
	}

}
