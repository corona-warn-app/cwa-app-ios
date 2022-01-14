////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HomeTableViewModelTests: CWATestCase {

	func testSectionsRowsAndHeights() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let badgeWrapper = HomeBadgeWrapper.fake()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: badgeWrapper
			),
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)

		// Number of Sections
		XCTAssertEqual(viewModel.numberOfSections, 6)
		
		// Number of Rows per Section
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 1)

		// Check riskAndTestResultsRows
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk])
	}

	func testRiskAndTestRowsIfKeysSubmitted() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(
			registrationToken: "FAKETOKEN!",
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: true
		)
		
		let badgeWrapper = HomeBadgeWrapper.fake()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: badgeWrapper
			),
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}
	
	func testRiskAndTestRowsIfPositiveTestResultWasShown() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(
			registrationToken: "FAKETOKEN!",
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: false
		)
		let badgeWrapper = HomeBadgeWrapper.fake()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: badgeWrapper
			),
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}

	func testRowHeightsWithoutStatistics() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: badgeWrapper
			),
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)
		viewModel.state.statistics.keyFigureCards = []

		for section in HomeTableViewModel.Section.allCases.map({ $0.rawValue }) {
			for row in 0..<viewModel.numberOfRows(in: section) {
				XCTAssertEqual(
					viewModel.heightForRow(at: IndexPath(row: row, section: section)),
					section == HomeTableViewModel.Section.statistics.rawValue ? 0 : UITableView.automaticDimension
				)
			}
		}
	}

	func testRowHeightsWithStatistics() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let badgeWrapper = HomeBadgeWrapper.fake()
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: badgeWrapper
			),
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)
		viewModel.state.updateStatistics()

		for section in HomeTableViewModel.Section.allCases.map({ $0.rawValue }) {
			for row in 0..<viewModel.numberOfRows(in: section) {
				XCTAssertEqual(
					viewModel.heightForRow(at: IndexPath(row: row, section: section)),
					UITableView.automaticDimension
				)
			}
		}
	}

	func testShouldShowDeletionConfirmationAlert() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let badgeWrapper = HomeBadgeWrapper.fake()
		let coronaTestService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(restServiceProvider: RestServiceProviderStub.fake())
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: badgeWrapper
		)

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: coronaTestService,
			onTestResultCellTap: { _ in },
			badgeWrapper: badgeWrapper
		)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = nil
		coronaTestService.antigenTest = .mock(testResult: .expired)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = .mock(testResult: .expired)
		coronaTestService.antigenTest = nil

		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = .mock(testResult: .pending)
		coronaTestService.antigenTest = .mock(testResult: .pending)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = .mock(testResult: .negative)
		coronaTestService.antigenTest = .mock(testResult: .negative)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = .mock(testResult: .positive)
		coronaTestService.antigenTest = .mock(testResult: .positive)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest = .mock(testResult: .invalid)
		coronaTestService.antigenTest = .mock(testResult: .invalid)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))
	}

}
