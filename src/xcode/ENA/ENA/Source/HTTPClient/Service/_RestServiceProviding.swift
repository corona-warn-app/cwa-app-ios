//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Protocol to define a public interface
*/
protocol RestServiceProviding {
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel?,  ServiceError<R.CustomError>>) -> Void
	) where R: Resource
}
