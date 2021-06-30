//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol LocalStatisticsProviding {
	func latestLocalStatistics(groupID: GroupIdentifier, eTag: String?) -> AnyPublisher<SAP_Internal_Stats_LocalStatistics, Error>
}

protocol LocalStatisticsFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }

	typealias LocalStatisticsCompletionHandler = (Result<LocalStatisticsResponse, Error>) -> Void
	// typealias GroupIdentifier = String

	func fetchLocalStatistics(
		groupID: GroupIdentifier,
		eTag: String?,
		completion: @escaping (Result<LocalStatisticsResponse, Error>) -> Void
	)
}

struct LocalStatisticsResponse {
	let localStatistics: SAP_Internal_Stats_LocalStatistics
	let eTag: String?
	let timestamp: Date
	let groupID: GroupIdentifier
	
	// typealias GroupIdentifier = String

	init(_ localStatistics: SAP_Internal_Stats_LocalStatistics, _ eTag: String? = nil, _ groupID: GroupIdentifier) {
		self.groupID = groupID
		self.localStatistics = localStatistics
		self.eTag = eTag
		self.timestamp = Date()
	}
}
