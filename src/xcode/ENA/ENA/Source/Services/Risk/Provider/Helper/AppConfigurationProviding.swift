//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

/// A provider of the app configuration struct
protocol AppConfigurationProviding: AnyObject {

	/// App configuration publisher that provides the latest app config or a locally stored default config.
	///
	/// - Parameter forceFetch: triggers a direct fetch ignoring the cache
	func appConfiguration(forceFetch: Bool) -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never>

	/// App configuration publisher that provides the latest app config or a locally stored default config.
	func appConfiguration() -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never>

	/// The list of partner countries provided by the app config, or the default country.
	func supportedCountries() -> AnyPublisher<[Country], Never>
}

/// Some requirements for app configuration handling
protocol AppConfigurationFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var packageVerifier: SignatureVerifier { get }

	typealias AppConfigResultHandler = ((Result<AppConfigurationFetchingResponse, Error>, Date?)) -> Void

	/// Request app configuration from backend
	/// - Parameters:
	///   - etag: an optional ETag to check with
	///   - completion: completion handler
	func fetchAppConfiguration(etag: String?, completion: @escaping AppConfigResultHandler)
}

/// Helper struct to collect some required data. Better than anonymous tumples.
struct AppConfigurationFetchingResponse {
	let config: SAP_Internal_V2_ApplicationConfigurationIOS
	let eTag: String?

	init(_ config: SAP_Internal_V2_ApplicationConfigurationIOS, _ eTag: String? = nil) {
		self.config = config
		self.eTag = eTag
	}
}
