////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HomeTableViewModelTests: CWATestCase {

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
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: MockCoronaTestService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
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
		let store = MockTestStore()

		let coronaTestService = MockCoronaTestService()
		coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest = true
		coronaTestService.pcrTest.value = PCRTest.mock(
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
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: coronaTestService,
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1)
		XCTAssertEqual(viewModel.riskAndTestResultsRows, [.pcrTestResult(.positiveResultWasShown)])
	}
	
	func testRiskAndTestRowsIfPositiveTestResultWasShown() {
		let store = MockTestStore()

		let coronaTestService = MockCoronaTestService()
		coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest = true
		coronaTestService.pcrTest.value = PCRTest.mock(
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
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: coronaTestService,
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
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
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: MockCoronaTestService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
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
				),
				localStatisticsProvider: LocalStatisticsProvider(
					client: CachingHTTPClientMock(),
					store: store
				)
			),
			store: store,
			coronaTestService: MockCoronaTestService(),
			onTestResultCellTap: { _ in },
			badgeWrapper: .fake()
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
		let store = MockTestStore()

		let coronaTestService = MockCoronaTestService()

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
			badgeWrapper: .fake()
		)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = nil
		coronaTestService.antigenTest.value = .mock(testResult: .expired)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .expired)
		coronaTestService.antigenTest.value = nil

		XCTAssertTrue(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .pending)
		coronaTestService.antigenTest.value = .mock(testResult: .pending)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .negative)
		coronaTestService.antigenTest.value = .mock(testResult: .negative)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .positive)
		coronaTestService.antigenTest.value = .mock(testResult: .positive)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))

		coronaTestService.pcrTest.value = .mock(testResult: .invalid)
		coronaTestService.antigenTest.value = .mock(testResult: .invalid)

		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .pcr))
		XCTAssertFalse(viewModel.shouldShowDeletionConfirmationAlert(for: .antigen))
	}

}
