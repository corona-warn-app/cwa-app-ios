////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
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
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
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
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
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
		XCTAssertEqual(healthCertificate.name.fullName, "Erika Dörte Schmitt Mustermann")
	}

	func testGIVEN_FullyVaccinatedHealthCertifiedPersonViewModel_THEN_isSetupCorrect() throws {
		// GIVEN
		let service = HealthCertificateService(
			store: MockTestStore(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertificate1 = try healthCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try healthCertificate(daysOffset: -12, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate1,
				healthCertificate2
			]
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {}
		)

		let fullyVaccinatedHintCellViewModel = viewModel.fullyVaccinatedHintCellViewModel
		guard case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection) = healthCertifiedPerson.vaccinationState else {
			fatalError("Cell cannot be shown in any other vaccination state than .fullyVaccinated")
		}

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .fullyVaccinatedHint), 1)
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.backgroundColor, .enaColor(for: .cellBackground2))
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.textAlignment, .left)
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.text, String(
			format: AppStrings.HealthCertificate.Person.daysUntilCompleteProtection,
			daysUntilCompleteProtection
		))
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.topSpace, 16.0)
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.font, .enaFont(for: .body))
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.borderColor, .enaColor(for: .hairline))
		XCTAssertEqual(fullyVaccinatedHintCellViewModel.accessibilityTraits, .staticText)

	}

}
