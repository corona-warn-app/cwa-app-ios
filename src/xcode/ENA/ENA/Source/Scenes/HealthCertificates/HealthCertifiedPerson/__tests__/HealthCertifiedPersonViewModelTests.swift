////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable type_body_length
class HealthCertifiedPersonViewModelTests: XCTestCase {

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_Init_THEN_isAsExpected() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(healthCertificates: [HealthCertificate.mock()]),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .header), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .boosterNotification), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .admissionState), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationState), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .person), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .certificates), 1)

		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.header.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.qrCode.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.boosterNotification.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.admissionState.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.vaccinationState.rawValue)))
		XCTAssertFalse(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.person.rawValue)))
		XCTAssertTrue(viewModel.canEditRow(at: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.numberOfSections, 7)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(0), .header)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(2), .boosterNotification)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(3), .admissionState)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(4), .vaccinationState)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(5), .person)
		XCTAssertEqual(HealthCertifiedPersonViewModel.TableViewSection.map(6), .certificates)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_qrCodeCellViewModel_THEN_noFatalError() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService, healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [
					HealthCertificate.mock()
				]
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// WHEN
		let qrCodeCellViewModel = viewModel.qrCodeCellViewModel
		let healthCertificateCellViewModel = viewModel.healthCertificateCellViewModel(row: 0)
		let healthCertificate = try XCTUnwrap(viewModel.healthCertificate(for: IndexPath(row: 0, section: HealthCertifiedPersonViewModel.TableViewSection.certificates.rawValue)))

		// THEN
		XCTAssertFalse(viewModel.vaccinationStateIsVisible)
		XCTAssertEqual(qrCodeCellViewModel.qrCodeViewModel.accessibilityLabel, AppStrings.HealthCertificate.Person.QRCodeImageDescription)
		XCTAssertEqual(healthCertificateCellViewModel.gradientType, .lightBlue)
		XCTAssertEqual(healthCertificate.name.fullName, "Erika Dörte Schmitt Mustermann")
	}

	func testHeightForFooter() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let healthCertificate = try vaccinationCertificate(daysOffset: -24, doseNumber: 1, identifier: "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S", dateOfBirth: "1988-06-07")

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				healthCertificate
			]
		)
		
		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.heightForFooter(in: .header), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .qrCode), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .vaccinationState), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .person), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: .certificates), 12)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_BoosterNotificationIsSetToVisible_THEN_CellIsVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					boosterNotification: .fake(visible: true)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .boosterNotification), 1)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_BoosterNotificationIsSetToNotVisible_THEN_CellIsNotVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					boosterNotification: .fake(visible: false)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .boosterNotification), 0)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_AdmissionStateIsSetToVisible_THEN_CellIsVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					admissionState: .fake(visible: true)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .admissionState), 1)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_AdmissionStateIsSetToNotVisible_THEN_CellIsNotVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					admissionState: .fake(visible: false)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .admissionState), 0)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_VaccinationStateIsSetToVisible_THEN_CellIsVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					vaccinationState: .fake(visible: true)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationState), 1)
	}

	func testGIVEN_HealthCertifiedPersonViewModel_WHEN_VaccinationStateIsSetToNotVisible_THEN_CellIsNotVisible() {
		// GIVEN
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake()
		)

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: HealthCertifiedPerson(
				healthCertificates: [HealthCertificate.mock()],
				dccWalletInfo: .fake(
					vaccinationState: .fake(visible: false)
				)
			),
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { _ in },
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationState), 0)
	}

	func testBoosterNotificationCellTap() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let cclService = FakeCCLService()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
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

		let expectation = expectation(description: "didTapBoosterNotification is called")

		let viewModel = HealthCertifiedPersonViewModel(
			cclService: cclService,
			healthCertificateService: service,
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificateValueSetsProvider: VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore()),
			dismiss: {},
			didTapBoosterNotification: { person in
				XCTAssertEqual(person, healthCertifiedPerson)
				expectation.fulfill()
			},
			didTapValidationButton: { _, _ in },
			showInfoHit: { }
		)

		viewModel.didTapBoosterNotificationCell()

		waitForExpectations(timeout: .short)
	}

}
