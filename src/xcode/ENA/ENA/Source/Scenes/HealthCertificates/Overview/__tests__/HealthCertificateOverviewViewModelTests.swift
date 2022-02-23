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
			healthCertificateService: service,
			healthCertificateRequestService: requestService
		)

		// THEN
		XCTAssertEqual(viewModel.numberOfSections, 4)
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 0)
	}

	func testGIVEN_requestTestCertificate_THEN_noErrorIsSet() {
		// GIVEN
		let viewModel = HealthCertificateOverviewViewModel(
			healthCertificateService: service,
			healthCertificateRequestService: requestService
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
