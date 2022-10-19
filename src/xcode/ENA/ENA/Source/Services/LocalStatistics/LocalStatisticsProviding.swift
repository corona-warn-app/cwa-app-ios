//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol LocalStatisticsProviding {
	var regionStatisticsData: OpenCombine.CurrentValueSubject<[RegionStatisticsData], Never> { get }
	var hasNewRegion: Bool { get }
	
	func add(_ region: LocalStatisticsRegion)
	func remove(_ region: LocalStatisticsRegion)
	func updateLocalStatistics(completion: ((Result<Void, Error>) -> Void)?)
}

protocol LocalStatisticsFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }

	typealias LocalStatisticsCompletionHandler = (Result<LocalStatisticsResponse, Error>) -> Void

	func fetchLocalStatistics(
		groupID: StatisticsGroupIdentifier,
		eTag: String?,
		completion: @escaping (Result<LocalStatisticsResponse, Error>) -> Void
	)
}

struct LocalStatisticsResponse {
	let localStatistics: SAP_Internal_Stats_LocalStatistics
	let eTag: String?
	let timestamp: Date
	let groupID: StatisticsGroupIdentifier

	init(_ localStatistics: SAP_Internal_Stats_LocalStatistics, _ eTag: String? = nil, _ groupID: StatisticsGroupIdentifier) {
		self.groupID = groupID
		self.localStatistics = localStatistics
		self.eTag = eTag
		self.timestamp = Date()
	}
}
