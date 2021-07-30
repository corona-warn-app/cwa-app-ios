//
// 🦠 Corona-Warn-App
//

import Foundation

protocol LocalStatisticsProviding {
	var cachedSelectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple] { get }

	func latestLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String?, completion: @escaping (Result<SAP_Internal_Stats_LocalStatistics, Error>) -> Void)
	func latestSelectedLocalStatistics(selectedLocalStatisticsRegions: [LocalStatisticsRegion], completion: @escaping ([SelectedLocalStatisticsTuple]) -> Void)
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
