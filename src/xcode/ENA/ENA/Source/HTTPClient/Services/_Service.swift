//
// 🦠 Corona-Warn-App
//

import Foundation


enum ServiceError: Error {
	case serverError(Error?)
	case unexpectedResponse(Int)
	case decodeError
}

protocol Service {

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource
	
}
