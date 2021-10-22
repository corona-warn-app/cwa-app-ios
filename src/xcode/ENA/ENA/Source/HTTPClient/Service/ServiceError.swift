//
// 🦠 Corona-Warn-App
//

/**
The errors that can occur while using the service and calling http methods.
*/
enum ServiceError<RE>: Error, Equatable where RE: Error {
	case transportationError(Error?)
	case unexpectedServerError(Int)
	case resourceError(ResourceError?)
	case receivedResourceError(RE)

	// MARK: - Protocol Equatable

	static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
		switch (lhs, rhs) {

		case let (.transportationError(lError), .transportationError(rError)):
			return lError?.localizedDescription == rError?.localizedDescription
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

			// toDo: equal cases
		case (.receivedResourceError(_), _):
			return false
		}
	}
}
