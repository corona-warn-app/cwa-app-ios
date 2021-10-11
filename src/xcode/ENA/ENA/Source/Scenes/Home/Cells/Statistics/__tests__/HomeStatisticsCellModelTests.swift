//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class HomeStatisticsCellModelTests: CWATestCase {

	func testForwardingSupportedKeyFigureCards() throws {
		let store = MockTestStore()
		let localStatisticsProvider = LocalStatisticsProvider(
			client: CachingHTTPClientMock(),
			store: store
		)

		let homeState = HomeState(
			store: store,
			riskProvider: MockRiskProvider(),
			exposureManagerState: ExposureManagerState(authorized: true, enabled: true, status: .active),
			enState: .enabled,
			statisticsProvider: StatisticsProvider(
				client: CachingHTTPClientMock(),
				store: store
			),
			localStatisticsProvider: localStatisticsProvider
		)
		homeState.statistics.keyFigureCards = []

		let cellModel = HomeStatisticsCellModel(
			homeState: homeState,
			localStatisticsProvider: localStatisticsProvider
		)

		let sinkExpectation = expectation(description: "keyFigureCards received")
		sinkExpectation.expectedFulfillmentCount = 2

		var receivedValues = [[SAP_Internal_Stats_KeyFigureCard]]()
		let subscription = cellModel.$keyFigureCards.sink {
			receivedValues.append($0)
			sinkExpectation.fulfill()
		}

		var loadedStatistics = SAP_Internal_Stats_Statistics()
		loadedStatistics.cardIDSequence = [1, 3, 10, 2]
		loadedStatistics.keyFigureCards = [keyFigureCard(cardID: 1), keyFigureCard(cardID: 3), keyFigureCard(cardID: 10), keyFigureCard(cardID: 2)]

		homeState.statistics = loadedStatistics

		waitForExpectations(timeout: .short)

		XCTAssertEqual(
			receivedValues,
			[[], [keyFigureCard(cardID: 1), keyFigureCard(cardID: 3), keyFigureCard(cardID: 10)]]
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

	private func administrativeUnitData(
		administrativeUnitShortID: UInt32 = 0
	) -> SAP_Internal_Stats_AdministrativeUnitData {
		var administrativeUnitData = SAP_Internal_Stats_AdministrativeUnitData()
		administrativeUnitData.administrativeUnitShortID = administrativeUnitShortID
		var sevenDayIncidence = SAP_Internal_Stats_SevenDayIncidenceData()
		sevenDayIncidence.trend = .increasing
		sevenDayIncidence.value = 50
		administrativeUnitData.sevenDayIncidence = sevenDayIncidence
		return administrativeUnitData
	}
}
