//
// 🦠 Corona-Warn-App
//

import Foundation

extension URLSession {
	class func coronaWarnSession() -> URLSession {
		#if DISABLE_CERTIFICATE_PINNING
		/// Disable certificate pinning while app is running on:
		/// Community, Debug, TestFlight, UITesting modes
		let coronaWarnURLSessionDelegate: CoronaWarnURLSessionDelegate? = nil
		#else
		let coronaWarnURLSessionDelegate = CoronaWarnURLSessionDelegate(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHash
		)
		#endif
		return URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: .main
		)
		
	}
}
