//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
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
	}

	// MARK: - Internal

	@OpenCombine.Published private(set) var keyFigureCards = [SAP_Internal_Stats_KeyFigureCard]()

	// MARK: - Private

	private let homeState: HomeState
	private var subscriptions = Set<AnyCancellable>()

}
