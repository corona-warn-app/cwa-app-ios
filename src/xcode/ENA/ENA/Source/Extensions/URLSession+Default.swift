//
// 🦠 Corona-Warn-App
//

import Foundation

extension URLSession {
	class func coronaWarnSession(
		configuration: URLSessionConfiguration,
		delegateQueue: OperationQueue? = nil
	) -> URLSession {
		#if DISABLE_CERTIFICATE_PINNING
		/// Disable certificate pinning while app is running in Community or Debug mode
		let coronaWarnURLSessionDelegate: CoronaWarnURLSessionDelegate? = nil
		#else
		let coronaWarnURLSessionDelegate = CoronaWarnURLSessionDelegate(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHash
		)
		#endif
		return URLSession(
			configuration: configuration,
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: delegateQueue
		)
	}
}
