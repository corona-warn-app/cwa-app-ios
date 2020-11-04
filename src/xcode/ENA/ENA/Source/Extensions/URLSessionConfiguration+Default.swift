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


	/// Session config with caching policy `.useProtocolCachePolicy`
	///
	/// - Note: Caching is not realized via `NSURLCache` but via the internal SecureStore due to privacy concerns
	/// - Returns: A session url configuration that uses the same set of parameters like the default CWA config. Only exception is the usage of caching policies.
	class func cachingSessionConfiguration() -> URLSessionConfiguration {
		let config = coronaWarnSessionConfiguration()
		config.requestCachePolicy = .useProtocolCachePolicy
		return config
	}
}
