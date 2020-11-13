//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import Combine

/// A provider of the app configuration struct
protocol AppConfigurationProviding: AnyObject {
	typealias Completion = (Result<SAP_Internal_ApplicationConfiguration, Error>) -> Void


	/// App configuration publisher that provides the latest app config or a locally stored default config.
	///
	/// - Parameter forceFetch: triggers a direct fetch ignoring the cache
	func appConfiguration(forceFetch: Bool) -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never>

	/// App configuration publisher that provides the latest app config or a locally stored default config.
	func appConfiguration() -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never>
}

/// Some requirements for app configuration handling
protocol AppConfigurationFetching {
	var configuration: HTTPClient.Configuration { get }
	var session: URLSession { get }
	var packageVerifier: SAPDownloadedPackage.Verifier { get }

	typealias AppConfigResultHandler = ((Result<AppConfigurationFetchingResponse, Error>, Date?)) -> Void

	/// Request app configuration from backend
	/// - Parameters:
	///   - etag: an optional ETag to check with
	///   - completion: completion handler
	func fetchAppConfiguration(etag: String?, completion: @escaping AppConfigResultHandler)
}

/// Helper struct to collect some required data. Better than anonymous tumples.
struct AppConfigurationFetchingResponse {
	let config: SAP_Internal_ApplicationConfiguration
	let eTag: String?

	init(_ config: SAP_Internal_ApplicationConfiguration, _ eTag: String? = nil) {
		self.config = config
		self.eTag = eTag
	}
}
