//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Protocol to define a public interface
*/
protocol RestServiceProviding {
	// load ReceiveModel by service type
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource
	
	// get ReceiveModel if it's available inside a cache
	func cached<R>(
		_ resource: R
	) -> Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>> where R: Resource

	func resetCache<R>(
		for resource: R
	) where R: Resource

#if !RELEASE
	// helpers for the developer menu
	var isWifiOnlyActive: Bool { get }

	func updateWiFiSession(wifiOnly: Bool)

	func isDisabled(_ identifier: String) -> Bool

	func disable(_ identifier: String)

	func enable(_ identifier: String)

#endif

}
