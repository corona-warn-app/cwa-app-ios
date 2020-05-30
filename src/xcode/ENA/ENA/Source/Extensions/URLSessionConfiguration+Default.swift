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
}
