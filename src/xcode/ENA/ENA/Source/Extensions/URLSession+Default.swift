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
			publicKeyHash: "f30c3959de6b062374f037c505fb3864e1b0678086252ab457ddd97c729d06ab"
		)
		#endif
		return URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: coronaWarnURLSessionDelegate,
			delegateQueue: .main
		)
		
	}
}
