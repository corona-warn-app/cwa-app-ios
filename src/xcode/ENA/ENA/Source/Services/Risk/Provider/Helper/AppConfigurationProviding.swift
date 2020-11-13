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

/// A provider of the app configuration struct
protocol AppConfigurationProviding: AnyObject {
	typealias Completion = (Result<SAP_Internal_V2_ApplicationConfigurationIOS, Error>) -> Void

	/// Fetch the current app configuration, either the cached or a newly fetched one
	/// - Parameters:
	///   - forceFetch: triggers a direct fetch ignoring the cache
	///   - completion: result handler
	func appConfiguration(forceFetch: Bool, completion: @escaping Completion)

	/// Fetch the current app configuration, either the cached or a newly fetched one
	/// - Parameter completion: result handler
	func appConfiguration(completion: @escaping Completion)
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
	let config: SAP_Internal_V2_ApplicationConfigurationIOS
	let eTag: String?

	init(_ config: SAP_Internal_V2_ApplicationConfigurationIOS, _ eTag: String? = nil) {
		self.config = config
		self.eTag = eTag
	}
}
