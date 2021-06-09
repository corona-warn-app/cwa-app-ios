////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HealthCertifiedPersonViewModelTests: XCTestCase {

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_Init_THEN_isAsExpected() {
		// GIVEN
		let service = HealthCertificateService(
			store: MockTestStore(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(healthCertificates: []),
			vaccinationValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {}
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .header), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .fullyVaccinatedHint), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .person), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .certificates), 0)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.numberOfSections, 5)

		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(0), .header)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(2), .fullyVaccinatedHint)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(3), .person)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(4), .certificates)

	}

}
