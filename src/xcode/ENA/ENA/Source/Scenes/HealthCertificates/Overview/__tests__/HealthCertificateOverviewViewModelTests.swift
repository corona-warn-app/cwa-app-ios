////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateOverviewViewModelTests: XCTestCase {

	func testGIVEN_HealthCertificateOverviewViewModel_THEN_SetupIsCorrect() {
		// GIVEN
		let viewModel = HealthCertificateOverviewViewModel(
			store: MockTestStore(),
			healthCertificateService: service,
			healthCertificateRequestService: requestService,
			cclService: FakeCCLService()
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfSections, 7)
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 6), 0)
	}

	func testGIVEN_HealthCertificateOverviewViewModel_WHEN_dccAdmissionCheckScenariosEnabled_THEN_SetupIsCorrect() throws {
		// GIVEN
		var cclService = FakeCCLService()
		cclService.dccAdmissionCheckScenariosEnabled = true
		
		let viewModel = HealthCertificateOverviewViewModel(
			store: MockTestStore(),
			healthCertificateService: service,
			healthCertificateRequestService: requestService,
			cclService: cclService
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfSections, 7)
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 6), 0)
	}
	
	func testGIVEN_HealthCertificateOverviewViewModel_WHEN_dccAdmissionCheckScenariosEnabled_healthCertificates_THEN_SetupIsCorrect() throws {
		// GIVEN
		var cclService = FakeCCLService()
		cclService.dccAdmissionCheckScenariosEnabled = true
		
		let vaccinationCertificate1Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-03",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		
		let vaccinationCertificate2Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-06",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
	
		service.registerHealthCertificate(base45: vaccinationCertificate1Base45)
		service.registerHealthCertificate(base45: vaccinationCertificate2Base45)
		
		let viewModel = HealthCertificateOverviewViewModel(
			store: MockTestStore(),
			healthCertificateService: service,
			healthCertificateRequestService: requestService,
			cclService: cclService
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfSections, 7)
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 6), 0)
	}
	
	func testGIVEN_requestTestCertificate_THEN_noErrorIsSet() {
		// GIVEN
		let viewModel = HealthCertificateOverviewViewModel(
			store: MockTestStore(),
			healthCertificateService: service,
			healthCertificateRequestService: requestService,
			cclService: FakeCCLService()
		)

		requestService.registerAndExecuteTestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			retryExecutionIfCertificateIsPending: false,
			labId: "SomeLabId"
		)

		viewModel.retryTestCertificateRequest(at: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertNil(viewModel.$testCertificateRequestError.value)
	}

	// MARK: - Private

	private let service: HealthCertificateService = {
		HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
	}()

	private lazy var requestService: HealthCertificateRequestService = {
		HealthCertificateRequestService(
			store: MockTestStore(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			healthCertificateService: service
		)
	}()

}
