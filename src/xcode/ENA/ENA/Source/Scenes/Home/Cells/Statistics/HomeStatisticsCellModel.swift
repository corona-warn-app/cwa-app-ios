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
				self?.localAdministrativeUnitStatistics = localStatistics.administrativeUnitData
				self?.localFederalStateStatistics = localStatistics.federalStateData
				Log.debug("HomeState did update \(private: "\(self?.localAdministrativeUnitStatistics.count ?? -1) administrativeUnits.")", log: .localStatistics)
				Log.debug("HomeState did update \(private: "\(self?.localFederalStateStatistics.count ?? -1) localFederalStates.")", log: .localStatistics)
			}
			.store(in: &subscriptions)
		
		homeState.$selectedLocalStatistics
			.sink { [weak self] selectedLocalStatistics in
				  self?.selectedLocalStatistics = selectedLocalStatistics
				  Log.debug("HomeState did update. \(private: "\(self?.selectedLocalStatistics.count ?? -1)")", log: .localStatistics)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	/// The default set of 'global' statistics for every user
	@OpenCombine.Published private(set) var keyFigureCards = [SAP_Internal_Stats_KeyFigureCard]()
	@OpenCombine.Published private(set) var localAdministrativeUnitStatistics = [SAP_Internal_Stats_AdministrativeUnitData]()
	@OpenCombine.Published private(set) var localFederalStateStatistics = [SAP_Internal_Stats_FederalStateData]()
	@OpenCombine.Published private(set) var selectedLocalStatistics = [SelectedLocalStatisticsTuple]()

	// MARK: - Private

	private let homeState: HomeState
	private var subscriptions = Set<AnyCancellable>()

}
