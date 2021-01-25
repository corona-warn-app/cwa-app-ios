//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class HomeStatisticsCellModelTests: XCTestCase {

	func testForwardingSupportedKeyFigureCards() throws {
		let store = MockTestStore()

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			exposureSubmissionService: MockExposureSubmissionService(),
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(store: store),
				store: store
			)
		)
		homeState.statistics.keyFigureCards = []

		let cellModel = HomeStatisticsCellModel(
			homeState: homeState
		)

		let sinkExpectation = expectation(description: "keyFigureCards received")
		sinkExpectation.expectedFulfillmentCount = 2

		var receivedValues = [[SAP_Internal_Stats_KeyFigureCard]]()
		let subscription = cellModel.$keyFigureCards.sink {
			receivedValues.append($0)
			sinkExpectation.fulfill()
		}

		var loadedStatistics = SAP_Internal_Stats_Statistics()
		loadedStatistics.cardIDSequence = [1, 3, 2, 17]
		loadedStatistics.keyFigureCards = [keyFigureCard(cardID: 1), keyFigureCard(cardID: 2), keyFigureCard(cardID: 3), keyFigureCard(cardID: 17)]

		homeState.statistics = loadedStatistics

		waitForExpectations(timeout: .short)

		XCTAssertEqual(
			receivedValues,
			[[], [keyFigureCard(cardID: 1), keyFigureCard(cardID: 3), keyFigureCard(cardID: 2)]]
		)

		subscription.cancel()
	}

	// MARK: - Private

	private func keyFigureCard(
		cardID: Int32 = 0
	) -> SAP_Internal_Stats_KeyFigureCard {
		var cardHeader = SAP_Internal_Stats_CardHeader()
		cardHeader.cardID = cardID

		var card = SAP_Internal_Stats_KeyFigureCard()
		card.header = cardHeader

		return card
	}

}
