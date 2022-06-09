//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit

@testable import ENA

class HealthCertificateExportCertificatesInfoViewModelTests: XCTestCase {
	
	var sut: HealthCertificateExportCertificatesInfoViewModel!

    override func setUpWithError() throws {
		let healthCertificateService = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		sut = HealthCertificateExportCertificatesInfoViewModel(healthCertificateService: healthCertificateService, vaccinationValueSetsProvider: vaccinationValueSetsProvider)
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
	
	func testGIVEN_Title_THEN_AreCorrect() {
		// GIVEN
		let title = sut.title
		
		// THEN
		XCTAssertEqual(title, AppStrings.HealthCertificate.ExportCertificatesInfo.title)
	}
	
	func testGIVEN_HidesCloseButton_THEN_ShouldBeFalse() {
		// GIVEN
		let hidesCloseButton = sut.hidesCloseButton
		
		// THEN
		XCTAssertFalse(hidesCloseButton)
	}
}
