//
// 🦠 Corona-Warn-App
//

/**
The errors that can occur while using the service and calling http methods.
*/
enum ServiceError<RE>: Error, Equatable where RE: Error {
	case transportationError(Error)
	case unexpectedServerError(Int)
	case resourceError(ResourceError?)
	case receivedResourceError(RE)
	case invalidResponse
	case unknown

	// MARK: - Protocol Equatable

	// swiftlint:disable cyclomatic_complexity
	static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
		switch (lhs, rhs) {
		case let (.transportationError(lError), .transportationError(rError)):
			return lError.localizedDescription == rError.localizedDescription
		case (.transportationError, _):
			return false

		case let (.unexpectedServerError(lInt), .unexpectedServerError(rInt)):
			return lInt == rInt
		case (.unexpectedServerError, _):
			return false

		case let (.resourceError(lResourceError), .resourceError(rResourceError)):
			return lResourceError == rResourceError
		case (.resourceError, _):
			return false

		case let (.receivedResourceError(lError), .receivedResourceError(rError)):
			return lError.localizedDescription == rError.localizedDescription
		case (.receivedResourceError, _):
			return false
		case (.unknown, .unknown):
			return true
		case (.unknown, _):
			return false
		case (.invalidResponse, .invalidResponse):
			return true
		case (.invalidResponse, _):
			return false
		}
	}
}
