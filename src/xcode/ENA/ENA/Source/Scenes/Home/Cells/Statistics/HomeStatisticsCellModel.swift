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
				self?.keyFigureCards = statistics.supportedStatisticsCardIDSequence
					.compactMap { cardID in
						statistics.keyFigureCards.first { $0.header.cardID == cardID }
					}
				
				self?.linkCards = statistics.supportedLinkCardIDSequence
					.compactMap { cardID in
						statistics.linkCards.first { $0.header.cardID == cardID }
					}
				#if DEBUG
				if isUITesting {
					self?.setupMockLinkCards()
				}
				#endif
			}
			.store(in: &subscriptions)
		
		localStatisticsProvider.regionStatisticsData
			.sink { [weak self] newRegionStatisticsData in
				guard let self = self else { return }
				self.regionStatisticsData = newRegionStatisticsData
				Log.debug("Updating local statistics cell model. \(private: "\(self.regionStatisticsData.count)")", log: .localStatistics)
			}
			.store(in: &subscriptions)
		
		
		#if DEBUG
		if isUITesting, LaunchArguments.statistics.maximumRegionsSelected.boolValue {
			setupMockDataMaximumCards()
		}
		#endif
	}
	
	// MARK: - Internal
	
	/// The default set of 'global' statistics for every user
	var hasNewRegion: Bool {
		return localStatisticsProvider.hasNewRegion
	}
	
	@DidSetPublished private(set) var linkCards = [SAP_Internal_Stats_LinkCard]()
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
	
	#if DEBUG
	private func setupMockLinkCards() {
			let mockedPandemicLinkCardModel: SAP_Internal_Stats_LinkCard = .mock(cardID: HomeLinkCard.bmgPandemicRadar.rawValue)
			linkCards.append(mockedPandemicLinkCardModel)
	}

	private func setupMockDataMaximumCards() {
		var sevenDayIncidence = SAP_Internal_Stats_SevenDayIncidenceData()
		sevenDayIncidence.trend = .increasing
		sevenDayIncidence.value = 43.1

		let heidelbergData = RegionStatisticsData(
			region: LocalStatisticsRegion(
				federalState: .badenWürttemberg,
				name: "Heidelberg",
				id: "1432",
				regionType: .administrativeUnit
			),
			updatedAt: 1234,
			sevenDayIncidence: sevenDayIncidence,
			sevenDayHospitalizationIncidenceUpdatedAt: 1234,
			sevenDayHospitalizationIncidence: sevenDayIncidence
		)
		
		let mannheimData = RegionStatisticsData(
			region: LocalStatisticsRegion(
				federalState: .badenWürttemberg,
				name: "Mannheim",
				id: "1434",
				regionType: .administrativeUnit
			),
			updatedAt: 1234,
			sevenDayIncidence: sevenDayIncidence,
			sevenDayHospitalizationIncidenceUpdatedAt: 1234,
			sevenDayHospitalizationIncidence: sevenDayIncidence
		)
		
		let badenWuerttembergData = RegionStatisticsData(
			region: LocalStatisticsRegion(
				federalState: .badenWürttemberg,
				name: "Baden Württemberg",
				id: "2342",
				regionType: .federalState
			),
			updatedAt: 1234,
			sevenDayIncidence: sevenDayIncidence,
			sevenDayHospitalizationIncidenceUpdatedAt: 1234,
			sevenDayHospitalizationIncidence: sevenDayIncidence
		)
		
		let hessenData = RegionStatisticsData(
			region: LocalStatisticsRegion(
				federalState: .hessen,
				name: "Hessen",
				id: "1144",
				regionType: .federalState
			),
			updatedAt: 1234,
			sevenDayIncidence: sevenDayIncidence,
			sevenDayHospitalizationIncidenceUpdatedAt: 1234,
			sevenDayHospitalizationIncidence: sevenDayIncidence
		)
		
		let rheinlandPfalzData = RegionStatisticsData(
			region: LocalStatisticsRegion(
				federalState: .rheinlandPfalz,
				name: "Rheinland Pfalz",
				id: "1456",
				regionType: .federalState
			),
			updatedAt: 1234,
			sevenDayIncidence: sevenDayIncidence,
			sevenDayHospitalizationIncidenceUpdatedAt: 1234,
			sevenDayHospitalizationIncidence: sevenDayIncidence
		)

		self.regionStatisticsData = [heidelbergData, mannheimData, badenWuerttembergData, hessenData, rheinlandPfalzData]
	}
	#endif
}
