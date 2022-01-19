////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertifiedPersonViewModelTests: XCTestCase {

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_Init_THEN_isAsExpected() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(healthCertificates: [HealthCertificate.mock()]),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .header), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationHint), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .admissionState), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .person), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .certificates), 1)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.header.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.qrCode.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.vaccinationHint.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.person.rawValue)))
		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.numberOfSections, 6)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(0), .header)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(2), .admissionState)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(3), .vaccinationHint)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(4), .person)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(5), .certificates)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_qrCodeCellViewModel_THEN_noFatalError() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [
					HealthCertificate.mock()
				]
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// WHEN
		let qrCodeCellViewModel = viewModel.qrCodeCellViewModel
		let healthCertificateCellViewModel = viewModel.healthCertificateCellViewModel(row: 0)
		let healthCertificate = try XCTUnwrap(viewModel.healthCertificate(for: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		// THEN
		XCTAssertTrue(viewModel.vaccinationHintIsVisible)
		XCTAssertEqual(qrCodeCellViewModel.qrCodeViewModel.accessibilityLabel, AppStrings.HealthCertificate.Person.QRCodeImageDescription)
		XCTAssertEqual(healthCertificateCellViewModel.gradientType, .lightBlue)
		XCTAssertEqual(healthCertificate.name.fullName, "Erika Dörte Schmitt Mustermann")
	}

	func testGIVEN_PartiallyVaccinatedHealthCertifiedPersonViewModel_THEN_isSetupCorrect() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			]
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		let vaccinationHintCellViewModel = viewModel.vaccinationHintCellViewModel
		guard case .partiallyVaccinated = healthCertifiedPerson.vaccinationState else {
			fatalError("Expected vaccination state .partiallyVaccinated")
		}

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationHint), 1)
		XCTAssertEqual(vaccinationHintCellViewModel.description, AppStrings.HealthCertificate.Person.VaccinationHint.partiallyVaccinated)
	}

	func testGIVEN_FullyVaccinatedHealthCertifiedPersonViewModel_THEN_isSetupCorrect() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate1 = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try vaccinationCertificate(daysOffset: -12, doseNumber: 2, identifier: "01DE/84503/1119349007/DXSGWWLW40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

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
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		let vaccinationHintCellViewModel = viewModel.vaccinationHintCellViewModel
		guard case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection) = healthCertifiedPerson.vaccinationState else {
			fatalError("Expected vaccination state .fullyVaccinated")
		}

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationHint), 1)
		XCTAssertEqual(vaccinationHintCellViewModel.description, String(
			format: AppStrings.HealthCertificate.Person.VaccinationHint.daysUntilCompleteProtection,
			daysUntilCompleteProtection
		))
	}

	func testHeightForFooter() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			]
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.heightForFooter(in: .header), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .qrCode), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .vaccinationHint), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .person), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .certificates), 12)
	}


	func testVaccinationHintBooster() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate = try vaccinationCertificate(daysOffset: -24, doseNumber: 3, totalSeriesOfDoses: 2, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			]
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.heightForFooter(in: .vaccinationHint), 0)
	}

	func testVaccinationHintIncompleteBooster() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate1 = try vaccinationCertificate(daysOffset: -24, doseNumber: 3, totalSeriesOfDoses: 2, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")
		let healthCertificate2 = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, totalSeriesOfDoses: 2, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

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
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.heightForFooter(in: .vaccinationHint), 0)
	}


	func testMarkBoosterRuleAsSeen() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
			),
			recycleBin: .fake()
		)

		let healthCertificate = try vaccinationCertificate()

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			],
			boosterRule: .fake(),
			isNewBoosterRule: true
		)

		let viewModel = HealthCertifiedPersonViewModel(
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		XCTAssertTrue(healthCertifiedPerson.isNewBoosterRule)

		viewModel.markBoosterRuleAsSeen()

		XCTAssertFalse(healthCertifiedPerson.isNewBoosterRule)
	}

}
