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
		
		homeState.$selectedLocalStatistics
			.sink { [weak self] selectedLocalStatistics in
				  self?.selectedLocalStatistics = selectedLocalStatistics
				  Log.debug("HomeState did update. \(private: "\(self?.selectedLocalStatistics.count ?? -1)")", log: .localStatistics)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	let homeState: HomeState

	/// The default set of 'global' statistics for every user
	@DidSetPublished private(set) var keyFigureCards = [SAP_Internal_Stats_KeyFigureCard]()
	@DidSetPublished private(set) var selectedLocalStatistics = [SelectedLocalStatisticsTuple]()

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

}
