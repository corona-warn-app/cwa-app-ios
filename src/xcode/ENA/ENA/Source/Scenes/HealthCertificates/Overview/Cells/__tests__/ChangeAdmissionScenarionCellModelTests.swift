////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ChangeAdmissionScenarionCellModelTests: XCTestCase {

	func testGIVEN_CellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = changeAdmissionScenarionCellModel()

		// THEN
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary1))
		XCTAssertEqual(cellViewModel.iconImagePublisher.value, UIImage(named: "Icons_Admission_State"))
	}

}
