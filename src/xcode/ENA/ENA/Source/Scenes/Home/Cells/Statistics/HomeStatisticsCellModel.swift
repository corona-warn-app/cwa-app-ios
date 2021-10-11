//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HomeStatisticsCellModel {

	// MARK: - Init

	init(
		homeState: HomeState,
		localStatisticsProvider: LocalStatisticsProviding
	) {
		self.homeState = homeState
		self.localStatisticsProvider = localStatisticsProvider

		homeState.$statistics
			.sink { [weak self] statistics in
				self?.keyFigureCards = statistics.supportedCardIDSequence
					.compactMap { cardID in
						statistics.keyFigureCards.first { $0.header.cardID == cardID }
					}
			}
			.store(in: &subscriptions)
		
		localStatisticsProvider.regionStatisticsData
			.sink { [weak self] regionStatisticsData in
				  self?.regionStatisticsData = regionStatisticsData
				  Log.debug("Updating local statistics cell model. \(private: "\(self?.regionStatisticsData.count ?? -1)")", log: .localStatistics)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	/// The default set of 'global' statistics for every user
	@DidSetPublished private(set) var keyFigureCards = [SAP_Internal_Stats_KeyFigureCard]()
	@DidSetPublished private(set) var regionStatisticsData = [RegionStatisticsData]()

	func add(_ region: LocalStatisticsRegion) {
		localStatisticsProvider.add(region)
	}

	func remove(_ region: LocalStatisticsRegion) {
		localStatisticsProvider.remove(region)
	}

	// MARK: - Private

	private let homeState: HomeState
	private let localStatisticsProvider: LocalStatisticsProviding

	private var subscriptions = Set<AnyCancellable>()
	private var isCombinedIncidenceCardSupported: Bool {
		#if DEBUG
		if isUITesting {
			return !LaunchArguments.statistics.useMockedOldAppVersion.boolValue
		} else if isOldAppVersion {
			return false
		}
		#endif
		// we show the combined card 10 only for 2.13 or later, else we show 2 and 8
		let appVersionParts = Bundle.main.appVersion.split(separator: ".")
		guard appVersionParts.count == 3,
			  let majorAppVersion = Int(appVersionParts[0]),
			  let minorAppVersion = Int(appVersionParts[1]) else {
				  Log.error("Not able to retrieve current app version")
				  return false
			  }
		return  (majorAppVersion > 2 || majorAppVersion == 2 && minorAppVersion >= 13)
	}
}
