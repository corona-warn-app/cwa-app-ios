//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HomeStatisticsCellModel {

	// MARK: - Init

	init(
		homeState: HomeState
	) {
		self.homeState = homeState

		homeState.$statistics
			.sink { [weak self] statistics in
				self?.keyFigureCards = statistics.supportedCardIDSequence
					.compactMap { cardID in
						statistics.keyFigureCards.first { $0.header.cardID == cardID }
					}
			}
			.store(in: &subscriptions)

		homeState.$localStatistics
			.sink { [weak self] localStatistics in
				self?.localAdministrativeUnitStatistics = localStatistics
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published private(set) var keyFigureCards = [SAP_Internal_Stats_KeyFigureCard]()
	@OpenCombine.Published private(set) var localAdministrativeUnitStatistics: SelectedLocalStatisticsTuple = SelectedLocalStatisticsTuple(localStatisticsData: SAP_Internal_Stats_LocalStatistics(), localStatisticsDistrict: LocalStatisticsDistrict(federalState: LocalStatisticsFederalState(), districtName: "", districtId: ""))

	// MARK: - Private

	private let homeState: HomeState
	private var subscriptions = Set<AnyCancellable>()

}
