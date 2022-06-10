//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertificateExportCertificatesInfoViewModelTests: XCTestCase {
	
	var sut: HealthCertificateExportCertificatesInfoViewModel!

    override func setUpWithError() throws {
		sut = HealthCertificateExportCertificatesInfoViewModel(onDismiss: { _ in }, onNext: {})
    }

    override func tearDownWithError() throws {
        sut = nil
    }
	
	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_CellsAndSectionsCountAreCorrent() {
		// WHEN
		let dynamicTableViewModel = sut.dynamicTableViewModel
		
		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 4)
	}
	
	func testGIVEN_HidesCloseButton_THEN_ShouldBeFalse() {
		// GIVEN
		let hidesCloseButton = sut.hidesCloseButton
		
		// THEN
		XCTAssertFalse(hidesCloseButton)
	}
}
