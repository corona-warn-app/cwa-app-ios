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

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.header.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.qrCode.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.fullyVaccinatedHint.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.person.rawValue)))
		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.numberOfSections, 5)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(0), .header)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(2), .fullyVaccinatedHint)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(3), .person)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(4), .certificates)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_qrCodeCellViewModel_THEN_noFatalError() throws {
		// GIVEN
		let service = HealthCertificateService(
			store: MockTestStore(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [
					HealthCertificate.mock()
				]
			),
			vaccinationValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {}
		)

		// WHEN
		let qrCodeCellViewModel = viewModel.qrCodeCellViewModel
		let personCellViewModel = viewModel.personCellViewModel
		let healthCertificateCellViewModel = viewModel.healthCertificateCellViewModel(row: 0)
		let healthCertificate = try XCTUnwrap(viewModel.healthCertificate(for: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		// THEN
		XCTAssertFalse(viewModel.fullyVaccinatedHintIsVisible)
		XCTAssertEqual(qrCodeCellViewModel.accessibilityText, AppStrings.HealthCertificate.Person.QRCodeImageDescription)
		XCTAssertEqual(personCellViewModel.attributedText?.string, "Erika Dörte Schmitt Mustermann\ngeboren 12.08.1964")
		XCTAssertEqual(healthCertificateCellViewModel.gradientType, .lightBlue)
		XCTAssertEqual(healthCertificate.name.fullName, "Erika Dörte Schmitt Mustermann")
	}

}
