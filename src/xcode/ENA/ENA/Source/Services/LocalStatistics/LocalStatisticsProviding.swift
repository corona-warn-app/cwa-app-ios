//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

protocol LocalStatisticsProviding {
	func latestLocalStatistics(administrativeUnit: String, eTag: String?) -> AnyPublisher<SAP_Internal_Stats_LocalStatistics, Error>
}

protocol LocalStatisticsFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }

	typealias LocalStatisticsCompletionHandler = (Result<LocalStatisticsResponse, Error>) -> Void

	func fetchLocalStatistics(
		administrativeUnit: String,
		eTag: String?,
		completion: @escaping (Result<LocalStatisticsResponse, Error>) -> Void
	)
}

struct LocalStatisticsResponse {
	let localStatistics: SAP_Internal_Stats_LocalStatistics
	let eTag: String?
	let timestamp: Date

	init(_ localStatistics: SAP_Internal_Stats_LocalStatistics, _ eTag: String? = nil) {
		self.localStatistics = localStatistics
		self.eTag = eTag
		self.timestamp = Date()
	}
}
