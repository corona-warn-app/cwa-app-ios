//
// 🦠 Corona-Warn-App
//

import Foundation

enum ServiceError: Error, Equatable {
	case serverError(Error?)
	case unexpectedResponse(Int)
	case notModified
	case decodeError
	case cacheError

	// MARK: - Protocol Equatable

	static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
		switch (lhs, rhs) {

		case let (.serverError(lError), .serverError(rError)):
			return lError?.localizedDescription == rError?.localizedDescription
		case (.serverError, _):
			return false

		case let (.unexpectedResponse(lInt), .unexpectedResponse(rInt)):
			return lInt == rInt
		case (.unexpectedResponse, _):
			return false

		case (.notModified, .notModified):
			return true
		case (.notModified, _):
			return false

		case (.decodeError, .decodeError):
			return true
		case (.decodeError, _):
			return false

		case (.cacheError, .cacheError):
			return true
		case (.cacheError, _):
			return false

		}
	}
}

protocol Service {

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource

}
