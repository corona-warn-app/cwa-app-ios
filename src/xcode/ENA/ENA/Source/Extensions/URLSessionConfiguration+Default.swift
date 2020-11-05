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

import Foundation

extension URLSessionConfiguration {

	/// A strict session configuration denying usage of cookies and caching
	/// - Returns: The **default** session configuration for this app.
	class func coronaWarnSessionConfiguration() -> URLSessionConfiguration {
		let config = URLSessionConfiguration.ephemeral
		config.httpMaximumConnectionsPerHost = 1 // most reliable
		config.timeoutIntervalForRequest = 60
		config.timeoutIntervalForResource = 5 * 60
		config.httpCookieAcceptPolicy = .never // we don't like cookies - privacy
		config.httpShouldSetCookies = false // we never send cookies
		config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData // avoid stale data
		return config
	}


	/// CWA Session config but only valid in WiFi environments
	/// - Returns: the same as `.coronaWarnSessionConfiguration` but only for WiFi connections
	class func coronaWarnSessionConfigurationWifiOnly() -> URLSessionConfiguration {
		let config = coronaWarnSessionConfiguration()
		// no download over expensive network (cellular)
		config.allowsExpensiveNetworkAccess = false
		// no download in case user has activated the low data mode
		config.allowsConstrainedNetworkAccess = false
		// session shall not wait for connectivity to become available; fail immediately
		config.waitsForConnectivity = false
		return config
	}


	/// CWA Session config with caching policy `.useProtocolCachePolicy`
	///
	/// - Note: Caching is not realized via `NSURLCache` but via the internal SecureStore due to privacy concerns
	/// - Returns: A session url configuration that uses the same set of parameters like the default CWA config. Only exception is the usage of caching policies.
	class func cachingSessionConfiguration() -> URLSessionConfiguration {
		let config = coronaWarnSessionConfiguration()
		config.requestCachePolicy = .useProtocolCachePolicy
		return config
	}
}
