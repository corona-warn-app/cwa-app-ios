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
		let CoronaWarnSessionTaskDelegate: CoronaWarnSessionTaskDelegate? = nil
		#else
		let CoronaWarnSessionTaskDelegate = CoronaWarnSessionTaskDelegate()
		
		#endif
		return URLSession(
			configuration: configuration,
			delegate: CoronaWarnSessionTaskDelegate,
			delegateQueue: delegateQueue
		)
	}

	class func legacyCoronaWarnSession(
		configuration: URLSessionConfiguration,
		delegateQueue: OperationQueue? = nil,
		withPinning: Bool = true
	) -> URLSession {
		#if DISABLE_CERTIFICATE_PINNING
		/// Disable certificate pinning while app is running in Community or Debug mode
		let coronaWarnURLSessionDelegate: CoronaWarnURLSessionDelegate? = nil
		#else
		var coronaWarnURLSessionDelegate: CoronaWarnURLSessionDelegate?
		if withPinning {
			coronaWarnURLSessionDelegate = CoronaWarnURLSessionDelegate(
				publicKeyHash: Environments().currentEnvironment().pinningKeyHash
			)
		}

		#endif
		return URLSession(
			configuration: configuration,
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: delegateQueue
		)
	}
}
