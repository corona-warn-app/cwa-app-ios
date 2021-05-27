////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeTableViewModelTests: XCTestCase {

	func testSectionsRowsAndHeights() throws {
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
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: MockHealthCertificateService(),
			onTestResultCellTap: { _ in }
		)

		// Number of Sections
		XCTAssertEqual(viewModel.numberOfSections, 9)
		
		// Number of Rows per Section
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0) // HealthCertificates
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 1) // createHealthCertificate
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 6), 1)
		XCTAssertEqual(viewModel.numberOfRows(in: 7), 2)
		XCTAssertEqual(viewModel.numberOfRows(in: 8), 2)

		// Check riskAndTestResultsRows
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.risk])
		
		// Height for Header
		XCTAssertEqual(viewModel.heightForHeader(in: 0), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 1), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 2), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 3), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 4), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 5), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 6), 0)
		XCTAssertEqual(viewModel.heightForHeader(in: 7), 16)
		XCTAssertEqual(viewModel.heightForHeader(in: 8), 16)
		
		// Height for Footer
		XCTAssertEqual(viewModel.heightForFooter(in: 0), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 1), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 2), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 3), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 4), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 5), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 6), 0)
		XCTAssertEqual(viewModel.heightForFooter(in: 7), 12)
		XCTAssertEqual(viewModel.heightForFooter(in: 8), 24)
		
	}

	func testRiskAndTestRowsIfKeysSubmitted() {
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(
			registrationToken: "FAKETOKEN!",
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: true
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
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: ClientMock(),
				store: store,
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: MockHealthCertificateService(),
			onTestResultCellTap: { _ in }
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}
	
	func testRiskAndTestRowsIfPositiveTestResultWasShown() {
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(
			registrationToken: "FAKETOKEN!",
			testResult: .positive,
			positiveTestResultWasShown: true,
			keysSubmitted: false
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
				)
			),
			store: store,
			coronaTestService: CoronaTestService(
				client: ClientMock(),
				store: store,
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: MockHealthCertificateService(),
			onTestResultCellTap: { _ in }
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}

	func testRowHeightsWithoutStatistics() {
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
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: MockHealthCertificateService(),
			onTestResultCellTap: { _ in }
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
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: MockHealthCertificateService(),
			onTestResultCellTap: { _ in }
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
				diaryStore: MockDiaryStore(),
				appConfiguration: CachedAppConfigurationMock()
			),
			healthCertificateService: healthCertificateService, onTestResultCellTap: { _ in }
		)
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 0) // HealthCertificates

		_ = healthCertificateService.registerHealthCertificate(base45: HealthCertificate.mockBase45)

		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1) // HealthCertificates
	}

}
