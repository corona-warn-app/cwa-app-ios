////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class HomeVaccinationCellModelTests: XCTestCase {

	func test_WhenHealthCertifiedPersonIsAdded() {
		let healthCertificateService = MockHealthCertificateService()
		let store = MockTestStore()

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: ClientMock(),
				store: store,
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: healthCertificateService, onTestResultCellTap: { _ in }
		)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0) // HealthCertificates

		_ = healthCertificateService.registerHealthCertificate(base45: HealthCertificate.mockBase45)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1) // HealthCertificates
	}
}
