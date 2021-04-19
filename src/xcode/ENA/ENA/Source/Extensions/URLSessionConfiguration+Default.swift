//
// 🦠 Corona-Warn-App
//

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
		config.allowsCellularAccess = false
		if #available(iOS 13.0, *) {
			// no download over expensive network (cellular)
			config.allowsExpensiveNetworkAccess = false
			// no download in case user has activated the low data mode
			config.allowsConstrainedNetworkAccess = false
		}

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
