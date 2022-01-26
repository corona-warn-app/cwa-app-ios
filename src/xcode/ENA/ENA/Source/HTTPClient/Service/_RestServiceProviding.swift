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
	
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<(R.Receive.ReceiveModel, MetaData), ServiceError<R.CustomError>>) -> Void
	) where R: Resource

	// get ReceiveModel if it's available inside a cache
	func cached<R>(
		_ resource: R
	) -> Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>> where R: Resource

	func update(_ evaluateTrust: EvaluateTrust)
}

struct MetaData {
	var loadedFromCache: Bool
	var headers: [AnyHashable: Any]
}
