////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// A provider for statistics
protocol StatisticsProviding: class {

	/// Provides the latest statistics
	func statistics() -> AnyPublisher<SAP_Internal_Stats_Statistics, Error>
}

/// Provide fetching functions for statistical data
protocol StatisticsFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var signatureVerifier: SignatureVerifier { get }

	typealias StatisticsFetchingResultHandler = (Result<StatisticsFetchingResponse, Error>) -> Void

	/// Request the latest statistics from backend
	/// - Parameters:
	///   - etag: an optional ETag to check with
	///   - completion: completion handler
	func fetchStatistics(etag: String?, completion: @escaping StatisticsFetchingResultHandler)
}

/// Helper struct to collect some required data. Better than anonymous tumples.
struct StatisticsFetchingResponse {
	/// The fetched statistics
	let stats: SAP_Internal_Stats_Statistics
	/// Used for manual cache control
	let eTag: String?
	/// Used for manual cache control
	let timestamp: Date

	init(_ stats: SAP_Internal_Stats_Statistics, _ eTag: String? = nil) {
		self.stats = stats
		self.eTag = eTag
		timestamp = Date()
	}
}
