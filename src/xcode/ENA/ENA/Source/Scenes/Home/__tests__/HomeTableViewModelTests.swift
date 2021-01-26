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
				exposureSubmissionService: MockExposureSubmissionService(),
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(store: store),
					store: store
				)
			)
		)

		// Number of Sections
		XCTAssertEqual(viewModel.numberOfSections, 6, "Number of sections does not match.")
		
		// Number of Rows per Section
		XCTAssertEqual(viewModel.numberOfRows(in: 0), 1, "Number of rows in section 0 does not match.")
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 2, "Number of rows in section 1 does not match.")
		XCTAssertEqual(viewModel.numberOfRows(in: 2), 1, "Number of rows in section 2 does not match.")
		XCTAssertEqual(viewModel.numberOfRows(in: 3), 1, "Number of rows in section 2 does not match.")
		XCTAssertEqual(viewModel.numberOfRows(in: 4), 2, "Number of rows in section 3 does not match.")
		XCTAssertEqual(viewModel.numberOfRows(in: 5), 2, "Number of rows in section 4 does not match.")
		
		// Check riskAndTestRows
		XCTAssertEqual(viewModel.riskAndTestRows, [.risk, .testResult], "Risk and Test Rows does not match.")
		
		// Height for Header
		XCTAssertEqual(viewModel.heightForHeader(in: 0), 0, "Height for Header in Section 0 does not match.")
		XCTAssertEqual(viewModel.heightForHeader(in: 1), 0, "Height for Header in Section 1 does not match.")
		XCTAssertEqual(viewModel.heightForHeader(in: 2), 0, "Height for Header in Section 2 does not match.")
		XCTAssertEqual(viewModel.heightForHeader(in: 3), 0, "Height for Header in Section 2 does not match.")
		XCTAssertEqual(viewModel.heightForHeader(in: 4), 16, "Height for Header in Section 3 does not match.")
		XCTAssertEqual(viewModel.heightForHeader(in: 5), 16, "Height for Header in Section 4 does not match.")
		
		// Height for Footer
		XCTAssertEqual(viewModel.heightForFooter(in: 0), 0, "Height for Footer in Section 0 does not match.")
		XCTAssertEqual(viewModel.heightForFooter(in: 1), 0, "Height for Footer in Section 1 does not match.")
		XCTAssertEqual(viewModel.heightForFooter(in: 2), 0, "Height for Footer in Section 2 does not match.")
		XCTAssertEqual(viewModel.heightForFooter(in: 3), 0, "Height for Footer in Section 2 does not match.")
		XCTAssertEqual(viewModel.heightForFooter(in: 4), 16, "Height for Footer in Section 3 does not match.")
		XCTAssertEqual(viewModel.heightForFooter(in: 5), 32, "Height for Footer in Section 4 does not match.")
		
	}

	func testRiskAndTestRowsIfKeysSubmitted() {
		let store = MockTestStore()
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = Int64(Date().timeIntervalSince1970)
		
		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				exposureSubmissionService: MockExposureSubmissionService(),
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(store: store),
					store: store
				)
			)
		)
		
		XCTAssertEqual(viewModel.numberOfRows(in: 1), 1, "Number of rows in section 1 does not match.")
		
		XCTAssertEqual(viewModel.riskAndTestRows, [.thankYou], "Risk and Test Rows does not match.")
	}
	
	func testRiskAndTestRowsIfPositiveTestResultWasShown() {
		let store = MockTestStore()
		store.registrationToken = "FAKETOKEN!"
		store.positiveTestResultWasShown = true
		
		let sut = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				exposureSubmissionService: MockExposureSubmissionService(),
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(store: store),
					store: store
				)
			)
		)
		sut.state.testResult = .positive
		
		XCTAssertEqual(sut.numberOfRows(in: 1), 1, "Number of rows in section 1 does not match.")
		XCTAssertEqual(sut.riskAndTestRows, [.shownPositiveTestResult], "Risk and Test Rows does not match.")
	}

	func testRowHeightsWithoutStatistics() {
		let store = MockTestStore()

		let viewModel = HomeTableViewModel(
			state: .init(
				store: store,
				riskProvider: MockRiskProvider(),
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				enState: .enabled,
				exposureSubmissionService: MockExposureSubmissionService(),
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(store: store),
					store: store
				)
			)
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
				exposureSubmissionService: MockExposureSubmissionService(),
				statisticsProvider: StatisticsProvider(
					client: CachingHTTPClientMock(store: store),
					store: store
				)
			)
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

}
